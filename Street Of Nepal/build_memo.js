const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
        Header, Footer, AlignmentType, LevelFormat,
        TabStopType, TabStopPosition, HeadingLevel, BorderStyle, WidthType,
        ShadingType, PageNumber } = require("docx");
const fs = require("fs");
const path = require("path");

const OUTPUT_DIR = path.join(__dirname, "outputs");
fs.mkdirSync(OUTPUT_DIR, { recursive: true });

const FONT = "Arial";
const border = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const borders = { top: border, bottom: border, left: border, right: border };

function cell(text, opts = {}) {
  const { bold = false, width, fill, color = "000000", align = AlignmentType.LEFT, size = 20 } = opts;
  return new TableCell({
    borders,
    width: width ? { size: width, type: WidthType.DXA } : undefined,
    shading: fill ? { fill, type: ShadingType.CLEAR } : undefined,
    margins: { top: 80, bottom: 80, left: 120, right: 120 },
    children: [new Paragraph({
      alignment: align,
      children: [new TextRun({ text, bold, color, font: FONT, size })]
    })]
  });
}

function para(text, opts = {}) {
  const { bold = false, italics = false, size = 21, spacingAfter = 150, color } = opts;
  return new Paragraph({
    spacing: { after: spacingAfter },
    children: [new TextRun({ text, bold, italics, font: FONT, size, color })]
  });
}

function bullet(text) {
  return new Paragraph({
    numbering: { reference: "bullets", level: 0 },
    spacing: { after: 80 },
    children: [new TextRun({ text, font: FONT, size: 21 })]
  });
}

const riskColor = { High: "C00000", Medium: "BF8F00", Low: "548235" };
const riskFill = { High: "FCE4E4", Medium: "FFF2CC", Low: "E2EFDA" };

const doc = new Document({
  styles: {
    default: { document: { run: { font: FONT, size: 22 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 30, bold: true, font: FONT, color: "1F3864" },
        paragraph: { spacing: { before: 240, after: 130 }, outlineLevel: 0,
          border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: "1F3864", space: 4 } } } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 24, bold: true, font: FONT, color: "2E5395" },
        paragraph: { spacing: { before: 180, after: 100 }, outlineLevel: 1 } },
    ]
  },
  numbering: {
    config: [
      { reference: "bullets",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
    ]
  },
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840 },
        margin: { top: 1152, right: 1152, bottom: 1152, left: 1152 }
      }
    },
    headers: {
      default: new Header({
        children: [new Paragraph({
          alignment: AlignmentType.RIGHT,
          children: [new TextRun({ text: "Streets of Nepal — Internal Audit Memo", font: FONT, size: 16, color: "808080" })]
        })]
      })
    },
    footers: {
      default: new Footer({
        children: [new Paragraph({
          alignment: AlignmentType.CENTER,
          children: [
            new TextRun({ text: "Page ", font: FONT, size: 16, color: "808080" }),
            new TextRun({ children: [PageNumber.CURRENT], font: FONT, size: 16, color: "808080" }),
          ]
        })]
      })
    },
    children: [
      // ---------------- TITLE BLOCK ----------------
      new Paragraph({
        spacing: { after: 80 },
        children: [new TextRun({ text: "MEMORANDUM", bold: true, size: 36, font: FONT, color: "1F3864" })]
      }),
      new Paragraph({
        spacing: { after: 300 },
        children: [new TextRun({ text: "Standard Costing Variance Analysis — April 2026", italics: true, size: 24, font: FONT, color: "595959" })]
      }),

      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [1800, 7560],
        rows: [
          new TableRow({ children: [cell("To:", { bold: true, width: 1800 }), cell("Owner / Management, Streets of Nepal", { width: 7560 })] }),
          new TableRow({ children: [cell("From:", { bold: true, width: 1800 }), cell("Sandesh Lama Tamang, Internal Review", { width: 7560 })] }),
          new TableRow({ children: [cell("Date:", { bold: true, width: 1800 }), cell("May 1, 2026", { width: 7560 })] }),
          new TableRow({ children: [cell("Re:", { bold: true, width: 1800 }), cell("Standard Costing Variance Review — Findings and Recommendations for April 2026", { width: 7560 })] }),
        ]
      }),
      new Paragraph({ text: "", spacing: { after: 200 } }),

      // ---------------- PURPOSE AND SCOPE ----------------
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("Purpose and Scope")] }),
      para("This memo presents the results of a standard costing variance review covering Streets of Nepal\u2019s four signature dishes \u2014 Chicken Momos, Veg Thukpa, Chow Mein (Chicken), and Lamb Sekuwa \u2014 for the 26 operating days of April 2026. The review compares actual material and labor costs to management\u2019s established standard cost cards, calculates the resulting variances, and applies documented scenario heuristics to identify patterns that warrant further inquiry."),
      para("This review was performed because food cost control directly affects margin in a thin-margin restaurant operation, and because the kitchen manager\u2019s monthly bonus is tied to a favorable food cost variance result \u2014 a structure that, while common, creates an incentive worth testing for."),

      // ---------------- METHODOLOGY ----------------
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("Methodology")] }),
      para("Variances were calculated using standard formulas applied at the daily, per-dish level and aggregated for the month:"),
      bullet("Material Price Variance (MPV) = (Actual Price \u2212 Standard Price) \u00d7 Actual Quantity"),
      bullet("Material Quantity Variance (MQV) = (Actual Quantity \u2212 Standard Quantity) \u00d7 Standard Price"),
      bullet("Labor Rate Variance (LRV) = (Actual Rate \u2212 Standard Rate) \u00d7 Actual Hours"),
      bullet("Labor Efficiency Variance (LEV) = (Actual Hours \u2212 Standard Hours) \u00d7 Standard Rate"),
      para("Beyond the standard variance calculations, three documented heuristics were applied to the synthetic daily data: a price-clustering test, a labor-time consistency comparison across dishes, and a period-end shift test. The thresholds are portfolio assumptions created for this scenario. They are not industry benchmarks or formal significance tests, and they do not prove manipulation; they identify patterns that should be traced to source documentation.", { spacingAfter: 220 }),

      // ---------------- SUMMARY OF RESULTS ----------------
      new Paragraph({ pageBreakBefore: true, heading: HeadingLevel.HEADING_1, children: [new TextRun("Summary of Variance Results")] }),
      para("The company recorded a net favorable variance of approximately $119 for April, driven almost entirely by Chicken Momos. Viewed in isolation, this looks like a positive result. The detail below is less reassuring."),

      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [2400, 1560, 1560, 1560, 1560, 720],
        rows: [
          new TableRow({ children: [
            cell("Dish", { bold: true, width: 2400, fill: "2E5395", color: "FFFFFF" }),
            cell("Material Var.", { bold: true, width: 1560, fill: "2E5395", color: "FFFFFF", align: AlignmentType.CENTER }),
            cell("Labor Var.", { bold: true, width: 1560, fill: "2E5395", color: "FFFFFF", align: AlignmentType.CENTER }),
            cell("Total Var.", { bold: true, width: 1560, fill: "2E5395", color: "FFFFFF", align: AlignmentType.CENTER }),
            cell("Orders", { bold: true, width: 1560, fill: "2E5395", color: "FFFFFF", align: AlignmentType.CENTER }),
            cell("F/U", { bold: true, width: 720, fill: "2E5395", color: "FFFFFF", align: AlignmentType.CENTER }),
          ]}),
          new TableRow({ children: [
            cell("Chicken Momos", { width: 2400 }),
            cell("$56.80 U", { width: 1560, align: AlignmentType.CENTER }),
            cell("$(370.61) F", { width: 1560, align: AlignmentType.CENTER }),
            cell("$(313.81) F", { width: 1560, align: AlignmentType.CENTER, bold: true }),
            cell("2,204", { width: 1560, align: AlignmentType.CENTER }),
            cell("F", { width: 720, align: AlignmentType.CENTER, bold: true, color: "548235" }),
          ]}),
          new TableRow({ children: [
            cell("Chow Mein (Chicken)", { width: 2400 }),
            cell("$50.15 U", { width: 1560, align: AlignmentType.CENTER }),
            cell("$50.38 U", { width: 1560, align: AlignmentType.CENTER }),
            cell("$100.54 U", { width: 1560, align: AlignmentType.CENTER, bold: true }),
            cell("1,365", { width: 1560, align: AlignmentType.CENTER }),
            cell("U", { width: 720, align: AlignmentType.CENTER, bold: true, color: "C00000" }),
          ]}),
          new TableRow({ children: [
            cell("Lamb Sekuwa", { width: 2400 }),
            cell("$24.29 U", { width: 1560, align: AlignmentType.CENTER }),
            cell("$36.71 U", { width: 1560, align: AlignmentType.CENTER }),
            cell("$61.00 U", { width: 1560, align: AlignmentType.CENTER, bold: true }),
            cell("774", { width: 1560, align: AlignmentType.CENTER }),
            cell("U", { width: 720, align: AlignmentType.CENTER, bold: true, color: "C00000" }),
          ]}),
          new TableRow({ children: [
            cell("Veg Thukpa", { width: 2400 }),
            cell("$31.09 U", { width: 1560, align: AlignmentType.CENTER }),
            cell("$2.35 U", { width: 1560, align: AlignmentType.CENTER }),
            cell("$33.44 U", { width: 1560, align: AlignmentType.CENTER, bold: true }),
            cell("1,038", { width: 1560, align: AlignmentType.CENTER }),
            cell("U", { width: 720, align: AlignmentType.CENTER, bold: true, color: "C00000" }),
          ]}),
          new TableRow({ children: [
            cell("Company Total", { width: 2400, bold: true, fill: "D9E2F3" }),
            cell("$162.33 U", { width: 1560, align: AlignmentType.CENTER, bold: true, fill: "D9E2F3" }),
            cell("$(281.17) F", { width: 1560, align: AlignmentType.CENTER, bold: true, fill: "D9E2F3" }),
            cell("$(118.83) F", { width: 1560, align: AlignmentType.CENTER, bold: true, fill: "D9E2F3" }),
            cell("5,381", { width: 1560, align: AlignmentType.CENTER, bold: true, fill: "D9E2F3" }),
            cell("F", { width: 720, align: AlignmentType.CENTER, bold: true, color: "548235", fill: "D9E2F3" }),
          ]}),
        ]
      }),
      new Paragraph({ text: "", spacing: { after: 200 } }),
      para("Three of the four dishes are unfavorable overall, and material costs are unfavorable company-wide \u2014 the favorable company total exists only because Chicken Momos\u2019s labor variance is favorable by $370.61, more than offsetting unfavorable results everywhere else. A single dish driving the entire company result, in the direction that happens to satisfy a bonus threshold, is itself worth noting before getting to the statistical findings below.", { spacingAfter: 280 }),

      // ---------------- FINDINGS ----------------
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("Findings and Risk Ratings")] }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("Finding 1 \u2014 Material Price Variances Show Unusually Low Volatility (All Dishes)")] }),
      riskBadge("Medium"),
      para("Actual material prices for all four dishes were favorable on 100% of operating days in April, with coefficients of variation ranging from 0.36% to 1.14%. Under this project\u2019s documented 1.2% CV heuristic, the combination of low dispersion and uniformly favorable direction warrants tracing recorded prices to vendor invoices. The calculation alone cannot determine whether the cause is a contract price, a data-interface issue, manual smoothing, or another explanation."),
      para("Recommendation: Trace a sample of recorded \u201cactual\u201d material prices directly to vendor invoices and purchase orders for at least two weeks of the period. If invoice prices do not match the recorded actuals, this points to a data entry or system issue in how purchasing costs flow into the costing system \u2014 a control gap independent of any individual\u2019s intent.", { spacingAfter: 280 }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("Finding 2 \u2014 Chicken Momos Labor Time Shows Implausibly Low Variability")] }),
      riskBadge("High"),
      para("The day-to-day standard deviation of recorded labor minutes per order for Chicken Momos (0.30 minutes) is 60% of the median spread across the four dishes. Under the project\u2019s cross-dish heuristic, that difference warrants validating how labor minutes were captured. Possible explanations include a stable production process, rounding, manual estimation, copied entries, or a system configuration issue; the calculation does not distinguish among them."),
      para("This finding is rated High because labor time is the input directly tied to the kitchen manager\u2019s bonus metric, and Chicken Momos is the dish where this pattern appears.", { spacingAfter: 200 }),
      para("Recommendation: Review the source of labor time data for Chicken Momos specifically \u2014 confirm whether minutes are captured via time clock/POS integration or manually entered by the kitchen manager. If manual, implement a system-captured alternative (e.g., ticket-time stamps already available in most POS systems) so labor minutes are recorded independently of the person whose bonus depends on them.", { spacingAfter: 280 }),

      new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("Finding 3 \u2014 Chicken Momos Variances Improve Sharply in the Final Days of the Month")] }),
      riskBadge("High"),
      para("Average variance per order for Chicken Momos shifted from \u2212$0.118 (favorable) during days 1\u201323 to \u2212$0.306 (favorable) during days 24\u201326, a further improvement of $0.189 per order. In this synthetic scenario, no corresponding staffing or sourcing change was provided. The timing supports follow-up, but one month of descriptive data is insufficient to establish intent or a recurring period-end pattern."),
      para("Recommendation: Compare this pattern against the same days in the prior 2\u20133 months. If the late-month improvement recurs every month, that is a stronger signal than a one-time event and should prompt a direct conversation with the kitchen manager about how late-month figures are recorded, plus consideration of moving the bonus calculation window so it does not align predictably with reporting cutoffs.", { spacingAfter: 280 }),

      // ---------------- OVERALL ASSESSMENT ----------------
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("Overall Assessment")] }),
      para("None of these findings proves intentional manipulation. Plausible explanations include contract pricing, a stable kitchen process, rounding, a system-interface issue, or genuine productivity improvement. The combined pattern increases the priority of verifying the underlying source records; it does not replace that verification."),
      para("This memo concludes only that management should validate vendor prices, labor-time capture, and the late-month movement before relying on the reported variance for a compensation decision."),

      // ---------------- RECOMMENDATIONS SUMMARY ----------------
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("Recommendations Summary")] }),
      bullet("Trace a sample of recorded material prices to vendor invoices for all four dishes before relying on reported price variances."),
      bullet("Verify the source and method of labor time capture for Chicken Momos; move to a system-captured time source independent of the kitchen manager."),
      bullet("Management should determine whether to defer relying on the April variance for the bonus decision until the Chicken Momos labor and price source data is verified."),
      bullet("Review whether the bonus structure itself should be redesigned \u2014 for example, basing it on a metric less susceptible to single-point manual entry, or requiring secondary sign-off on the underlying data."),
      bullet("Repeat this variance and statistical review monthly so that any recurring late-month pattern becomes visible over time rather than being assessed one month at a time."),

      new Paragraph({ text: "", spacing: { after: 300 } }),
      para("Prepared as part of an internal cost accounting and controls review.", { italics: true, size: 18, color: "808080", spacingAfter: 0 }),
    ]
  }]
});

function riskBadge(level) {
  return new Paragraph({
    spacing: { after: 120 },
    children: [
      new TextRun({ text: "Risk Rating: ", bold: true, font: FONT, size: 22 }),
      new TextRun({ text: level, bold: true, font: FONT, size: 22, color: level === "High" ? "C00000" : level === "Medium" ? "BF8F00" : "548235" }),
    ]
  });
}

Packer.toBuffer(doc).then(buffer => {
  const outputPath = path.join(OUTPUT_DIR, "Streets_of_Nepal_Audit_Memo.docx");
  fs.writeFileSync(outputPath, buffer);
  console.log(`Saved ${outputPath}`);
});
