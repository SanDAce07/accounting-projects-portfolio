"""
Streets of Nepal - Standard Costing Variance Analysis Engine
==============================================================
Calculates material price/quantity and labor rate/efficiency variances
from daily actuals, then runs statistical tests to flag patterns that
are consistent with possible data manipulation or control weaknesses
(rather than ordinary operational variation).

Author: Sandesh Acharya
"""

import pandas as pd
import numpy as np

pd.set_option("display.float_format", lambda x: f"{x:,.2f}")

df = pd.read_csv("data/daily_actuals.csv")

# ------------------------------------------------------------------
# 1. VARIANCE CALCULATIONS
# ------------------------------------------------------------------
# Material Price Variance  = (Actual Price - Standard Price) x Actual Quantity
# Material Quantity Variance = (Actual Qty - Standard Qty) x Standard Price
# Labor Rate Variance = (Actual Rate - Standard Rate) x Actual Hours
# Labor Efficiency Variance = (Actual Hours - Standard Hours) x Standard Rate
#
# Negative = favorable (cost came in under standard)
# Positive = unfavorable (cost came in over standard)

df["Actual_Material_Qty_Total"] = df["Actual_Material_Qty_per_Order"] * df["Orders"]
df["Std_Material_Qty_Total"] = df["Std_Material_Qty_per_Order"] * df["Orders"]
df["Actual_Labor_Hours_Total"] = (df["Actual_Labor_Minutes_per_Order"] * df["Orders"]) / 60
df["Std_Labor_Hours_Total"] = (df["Std_Labor_Minutes_per_Order"] * df["Orders"]) / 60

df["MPV"] = (df["Actual_Material_Price"] - df["Std_Material_Price"]) * df["Actual_Material_Qty_Total"]
df["MQV"] = (df["Actual_Material_Qty_Total"] - df["Std_Material_Qty_Total"]) * df["Std_Material_Price"]
df["LRV"] = (df["Actual_Labor_Rate"] - df["Std_Labor_Rate"]) * df["Actual_Labor_Hours_Total"]
df["LEV"] = (df["Actual_Labor_Hours_Total"] - df["Std_Labor_Hours_Total"]) * df["Std_Labor_Rate"]

df["Total_Material_Variance"] = df["MPV"] + df["MQV"]
df["Total_Labor_Variance"] = df["LRV"] + df["LEV"]

df.to_csv("data/daily_variances.csv", index=False)

# ------------------------------------------------------------------
# 2. MONTHLY SUMMARY BY DISH
# ------------------------------------------------------------------
summary = df.groupby("Dish").agg(
    Total_Orders=("Orders", "sum"),
    MPV=("MPV", "sum"),
    MQV=("MQV", "sum"),
    LRV=("LRV", "sum"),
    LEV=("LEV", "sum"),
).reset_index()
summary["Total_Material_Variance"] = summary["MPV"] + summary["MQV"]
summary["Total_Labor_Variance"] = summary["LRV"] + summary["LEV"]
summary["Grand_Total_Variance"] = summary["Total_Material_Variance"] + summary["Total_Labor_Variance"]

print("=" * 70)
print("MONTHLY VARIANCE SUMMARY BY DISH (negative = favorable)")
print("=" * 70)
print(summary.to_string(index=False))

company_total = summary["Grand_Total_Variance"].sum()
print(f"\nCompany-wide net variance for April 2026: ${company_total:,.2f}")
print("(Favorable)" if company_total < 0 else "(Unfavorable)")

# ------------------------------------------------------------------
# 3. FORENSIC / RED-FLAG STATISTICAL TESTS
# ------------------------------------------------------------------
print("\n" + "=" * 70)
print("RED-FLAG DETECTION TESTS")
print("=" * 70)

flags = []

# TEST A: Price variance "too clean" test
# Real vendor price variation should show meaningful day-to-day spread.
# We compare the coefficient of variation (CV) of actual price vs standard
# price across days, by dish. An unusually low CV combined with a
# consistently favorable direction suggests the price data may not
# reflect genuine, independently-sourced vendor invoices.
print("\n--- TEST A: Material Price Variance Clustering ---")
for dish in df["Dish"].unique():
    sub = df[df["Dish"] == dish]
    cv = sub["Actual_Material_Price"].std() / sub["Actual_Material_Price"].mean()
    pct_favorable_days = (sub["MPV"] < 0).mean() * 100
    mean_pct_off_std = ((sub["Actual_Material_Price"] - sub["Std_Material_Price"]) / sub["Std_Material_Price"]).mean() * 100
    flagged = cv < 0.012 and pct_favorable_days > 90
    print(f"{dish:25s} CV={cv:.4f}  Favorable days={pct_favorable_days:5.1f}%  "
          f"Avg variance from std={mean_pct_off_std:+.2f}%  {'<-- FLAGGED' if flagged else ''}")
    if flagged:
        flags.append({
            "test": "Price Variance Clustering",
            "dish": dish,
            "detail": f"Coefficient of variation {cv:.4f} (unusually tight) with {pct_favorable_days:.0f}% "
                      f"of days favorable, averaging {mean_pct_off_std:+.2f}% vs standard. Real market "
                      f"prices typically show more day-to-day spread; this pattern is more consistent with "
                      f"smoothed or pre-adjusted data than independently sourced vendor invoices.",
            "risk": "Medium",
        })

# TEST B: Labor efficiency consistency test (cross-dish comparison)
# Compare the standard deviation of actual labor minutes per order across
# dishes. If one dish shows a standard deviation far below the others,
# that dish's time entries may not be independently recorded each day.
print("\n--- TEST B: Labor Time Consistency (cross-dish comparison) ---")
labor_std = df.groupby("Dish")["Actual_Labor_Minutes_per_Order"].std().sort_values()
print(labor_std.to_string())
median_std = labor_std.median()
for dish, std_val in labor_std.items():
    ratio = std_val / median_std
    flagged = ratio < 0.65
    print(f"{dish:25s} std={std_val:.3f} min  (ratio to median dish: {ratio:.2f}x)  {'<-- FLAGGED' if flagged else ''}")
    if flagged:
        flags.append({
            "test": "Labor Time Consistency",
            "dish": dish,
            "detail": f"Day-to-day standard deviation of recorded labor minutes ({std_val:.3f}) is only "
                      f"{ratio:.0%} of the typical spread seen in other dishes ({median_std:.3f}). Real "
                      f"kitchen labor time fluctuates with order complexity, staffing, and volume; this "
                      f"low variability suggests time entries may be estimated, copy-pasted, or pre-filled "
                      f"rather than recorded in real time, which is a labor-tracking control weakness.",
            "risk": "High",
        })

# TEST C: Period-end shift test
# Compares variance favorability in the final days of the month (closest
# to a bonus review date) against the rest of the month. A sharp,
# unexplained improvement right before a review date is a classic
# indicator of period-end earnings/metric management.
print("\n--- TEST C: Period-End Shift Test (days 24-26 vs days 1-23) ---")
for dish in df["Dish"].unique():
    sub = df[df["Dish"] == dish]
    early = sub[sub["Day"] <= 23]
    late = sub[sub["Day"] >= 24]
    early_avg_total_var_per_order = (early["Total_Material_Variance"] + early["Total_Labor_Variance"]).sum() / early["Orders"].sum()
    late_avg_total_var_per_order = (late["Total_Material_Variance"] + late["Total_Labor_Variance"]).sum() / late["Orders"].sum()
    shift = late_avg_total_var_per_order - early_avg_total_var_per_order
    flagged = shift < -0.05  # meaningfully more favorable per order in final days
    print(f"{dish:25s} Early avg var/order=${early_avg_total_var_per_order:+.3f}  "
          f"Late avg var/order=${late_avg_total_var_per_order:+.3f}  Shift=${shift:+.3f}  "
          f"{'<-- FLAGGED' if flagged else ''}")
    if flagged:
        flags.append({
            "test": "Period-End Shift",
            "dish": dish,
            "detail": f"Average variance per order moved from ${early_avg_total_var_per_order:+.3f} during "
                      f"days 1-23 to ${late_avg_total_var_per_order:+.3f} during days 24-26, a shift of "
                      f"${shift:+.3f} per order with no corresponding change in volume, staffing, or "
                      f"ingredient sourcing on file. This timing, immediately preceding month-end "
                      f"performance review, is consistent with period-end metric management.",
            "risk": "High",
        })

# ------------------------------------------------------------------
# 4. SAVE FLAGS FOR MEMO
# ------------------------------------------------------------------
flags_df = pd.DataFrame(flags)
flags_df.to_csv("data/red_flags.csv", index=False)

print("\n" + "=" * 70)
print(f"TOTAL RED FLAGS IDENTIFIED: {len(flags)}")
print("=" * 70)
for i, f in enumerate(flags, 1):
    print(f"\n{i}. [{f['risk']} RISK] {f['test']} - {f['dish']}")
    print(f"   {f['detail']}")

summary.to_csv("data/monthly_summary.csv", index=False)
print("\nSaved: data/daily_variances.csv, data/monthly_summary.csv, data/red_flags.csv")
