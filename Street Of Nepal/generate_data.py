import numpy as np
import pandas as pd
import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"
DATA_DIR.mkdir(parents=True, exist_ok=True)

np.random.seed(42)

# ---------------------------------------------------------------
# Standard cost cards
# ---------------------------------------------------------------
dishes = {
    "Chicken Momos": {
        "std_material_qty": 0.35,      # lbs of chicken filling per order
        "std_material_price": 3.80,    # $ per lb
        "std_labor_minutes": 6.0,
        "std_labor_rate": 13.50,       # $ per hour
        "unit": "lb",
    },
    "Veg Thukpa": {
        "std_material_qty": 0.60,      # lbs of mixed veg/noodle per bowl
        "std_material_price": 2.10,
        "std_labor_minutes": 8.0,
        "std_labor_rate": 13.50,
        "unit": "lb",
    },
    "Chow Mein (Chicken)": {
        "std_material_qty": 0.50,
        "std_material_price": 3.20,
        "std_labor_minutes": 7.0,
        "std_labor_rate": 13.50,
        "unit": "lb",
    },
    "Lamb Sekuwa": {
        "std_material_qty": 0.45,
        "std_material_price": 6.50,
        "std_labor_minutes": 10.0,
        "std_labor_rate": 14.50,       # grill station, slightly higher skill rate
        "unit": "lb",
    },
}

days = list(range(1, 27))  # 26 operating days in April 2026

# Daily order volume per dish (normal operational fluctuation)
base_volume = {"Chicken Momos": 85, "Veg Thukpa": 40, "Chow Mein (Chicken)": 55, "Lamb Sekuwa": 30}

records = []

for dish, card in dishes.items():
    sq = card["std_material_qty"]
    sp = card["std_material_price"]
    sh_min = card["std_labor_minutes"]
    sr = card["std_labor_rate"]

    for d in days:
        # Order volume: normal day-to-day fluctuation, slightly higher on weekends (every 6/7th day)
        vol = max(5, int(np.random.normal(base_volume[dish], base_volume[dish] * 0.12)))

        # ---- MATERIAL PRICE (actual $/lb paid) ----
        if dish in ["Chicken Momos", "Veg Thukpa", "Chow Mein (Chicken)", "Lamb Sekuwa"]:
            # RED FLAG 2: suspiciously tight, consistently favorable prices (low real variance)
            # Deliberately tight clustering for the synthetic control-testing scenario.
            noise = np.random.normal(0, 0.004)  # very tight clustering
            actual_price = sp * (1 - 0.018 + noise)  # consistently ~1.8% favorable, barely moves
        else:
            actual_price = sp * (1 + np.random.normal(0, 0.04))

        # ---- MATERIAL QUANTITY (actual lbs used per order, averaged) ----
        # Real waste/usage drifting unfavorable across the month, worse in later days
        drift = (d / 26) * 0.05  # waste creeps up over the month
        qty_noise = np.random.normal(0, 0.02)
        actual_qty = sq * (1 + 0.015 + drift + qty_noise)  # unfavorable, growing

        # ---- LABOR ----
        if dish == "Chicken Momos":
            # RED FLAG 3: too-consistent favorable labor efficiency (low std dev vs other dishes)
            labor_noise = np.random.normal(0, 0.15)  # very tight (real kitchens vary more)
            actual_minutes = sh_min * (1 - 0.10 + labor_noise / sh_min)
            actual_minutes = max(actual_minutes, sh_min * 0.75)
        else:
            # Normal kitchen variation - occasionally unfavorable, occasionally favorable
            labor_noise = np.random.normal(0, 0.6)
            actual_minutes = sh_min + labor_noise

        actual_rate = sr * (1 + np.random.normal(0, 0.01))  # rate is fairly stable (hourly wage)

        # RED FLAG 4: last 3 days of month show abrupt extra-favorable jump (bonus review at day 26)
        if dish == "Chicken Momos" and d >= 24:
            actual_minutes *= 0.85
            actual_price *= 0.97

        records.append({
            "Dish": dish,
            "Day": d,
            "Orders": vol,
            "Std_Material_Qty_per_Order": round(sq, 4),
            "Std_Material_Price": round(sp, 4),
            "Actual_Material_Price": round(actual_price, 4),
            "Actual_Material_Qty_per_Order": round(actual_qty, 4),
            "Std_Labor_Minutes_per_Order": round(sh_min, 4),
            "Std_Labor_Rate": round(sr, 4),
            "Actual_Labor_Minutes_per_Order": round(actual_minutes, 4),
            "Actual_Labor_Rate": round(actual_rate, 4),
        })

df = pd.DataFrame(records)
df.to_csv(DATA_DIR / "daily_actuals.csv", index=False)

with open(DATA_DIR / "standard_cost_cards.json", "w") as f:
    json.dump(dishes, f, indent=2)

print(df.shape)
print(df.head(10).to_string())
print(f"\nSaved {DATA_DIR / 'daily_actuals.csv'} and {DATA_DIR / 'standard_cost_cards.json'}")
