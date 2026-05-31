# Bright Motors Sales Performance Analysis

## Overview
This case study analyses historical vehicle sales data from Bright Motors to uncover actionable insights that support revenue growth, improved dealership profitability, inventory optimisation, and regional expansion.

The objective was to:
- Identify which car makes and models generate the most revenue
- Analyse the relationship between vehicle price, mileage, and year of manufacture
- Determine which regions drive the highest sales volumes and revenue
- Understand emerging customer purchasing preferences
- Provide data-driven recommendations to improve profitability and operational efficiency

---

## Approach & Methodology

The analysis was conducted using an end-to-end analytics workflow:

### 1. Project Planning
- Defined business objectives and key analytical questions
- Structured analysis approach and storytelling framework for executive presentation

### 2. Data Cleaning & Transformation (SQL | Databricks)
- Cleaned and standardised raw vehicle sales data
- Handled missing values, inconsistent formatting, and duplicate records
- Standardised categorical fields such as:
  - Make
  - Model
  - Body type
  - Transmission
  - Region
  - Colour
  - Interior

### 3. Feature Engineering
Created new analytical fields to support richer analysis:

- **Revenue Calculation**
  - Total Revenue

- **Profitability Metrics**
  - Profit
  - Profit Margin
  - Profit Tier (High / Medium / Low Margin)

- **Vehicle Metrics**
  - Car Age
  - Mileage Category
  - Price Band
  - Vehicle Segment

- **Time-Based Features**
  - Sale Year
  - Sale Quarter
  - Sale Month
  - Month Name
  - Day Name
  - Time of Sale
  - Time Bucket
  - Day Classification (Weekday vs Weekend)

### 4. Data Analysis (Excel)
Built pivot tables and visualisations to analyse:

- Revenue by make and model
- Profitability by make and price band
- Regional sales and profitability performance
- Monthly and quarterly sales trends
- Vehicle price vs mileage relationships
- Customer preferences:
  - Vehicle segment
  - Transmission
  - Body type
  - Colour

### 5. Dashboard Development (Looker Studio)
Built an interactive dashboard to support stakeholder exploration and decision-making.

Dashboard includes:
- Executive overview
- Revenue & profitability analysis
- Regional performance
- Inventory & pricing analysis
- Customer purchasing behaviour

**Dashboard Link:**  
[https://datastudio.google.com/s/jJSIDHtL87I]

### 6. Insights & Presentation
- Synthesised findings into executive-level business insights
- Developed recommendations aligned to profitability, growth, and operational efficiency
- Presented findings in a business-focused strategy presentation

---

## Key Insights

- **Revenue Concentration Risk:**  
  Revenue is heavily concentrated among a small portfolio of brands, with Ford, Chevrolet, Nissan, Toyota, and BMW contributing the majority of revenue.

- **Regional Sales Concentration:**  
  Sales are concentrated in Florida, California, Pennsylvania, and Texas, highlighting strong regional performance and dealership expansion opportunities.

- **Mileage Impacts Vehicle Pricing:**  
  Vehicle selling price declines as mileage increases, while lower-mileage vehicles consistently command higher prices.

- **Newer Vehicles Command Higher Prices:**  
  Newer vehicles achieve stronger average selling prices, supporting the strategic value of maintaining newer inventory.

- **Customer Demand Concentration:**  
  Customer demand is concentrated in:
  - Mid-range vehicles
  - Passenger vehicles
  - Automatic transmission vehicles
  - Neutral colours (black, white, silver, grey)

- **Profitability Leakage:**  
  Several high-volume brands and regions underperform on profitability despite strong revenue contribution.

- **Seasonality Patterns:**  
  Sales activity peaks during Q1 and early-year months, indicating strong seasonality trends.

---

## Recommendations

- **Optimise Inventory Mix:**  
  Prioritise stocking:
  - High-performing makes and models
  - Mid-range passenger vehicles
  - Automatic vehicles
  - Low-to-medium mileage vehicles

- **Improve Margin Performance:**  
  Review pricing strategy, sourcing costs, and discounting practices for loss-making brands and regions.

- **Regional Expansion Strategy:**  
  Prioritise dealership expansion and targeted campaigns in high-performing regions.

- **Seasonal Planning:**  
  Align inventory procurement and marketing campaigns to peak demand periods, particularly Q1.

- **Demand-Based Product Strategy:**  
  Increase inventory allocation toward newer vehicles and high-demand body types to improve turnover and pricing power.

- **Operational Efficiency:**  
  Align staffing and dealership operations with peak transaction periods based on weekday and time-of-day sales behaviour.

---

## Tools Used

- **Databricks (SQL)** → Data cleaning, transformation, feature engineering
- **Microsoft Excel** → Data analysis (Pivot Tables) and visualisation
- **Looker Studio** → Interactive dashboard development
- **PowerPoint** → Executive presentation and recommendations

---

## Outcome

This case study demonstrates how data analytics can be leveraged to:

- Identify key revenue and profitability drivers
- Understand customer purchasing behaviour
- Optimise inventory and product mix
- Improve operational efficiency
- Support strategic dealership growth and regional expansion

The analysis shifts Bright Motors from reactive sales reporting toward **data-driven commercial decision-making and profitable growth optimisation**.

---

## Contact

For questions, feedback, or collaboration opportunities:

**LinkedIn:**  
www.linkedin.com/in/refilwe-mofokeng
