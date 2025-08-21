# Customer-Retention-Analysis

# Table of Contents
- [Summary](#Summary)
- [Project Goal](#Project-Goals)
- [Introduction](#Introduction)
- [Key Insights](#Key-Insights)
- [Dashboard](#Dashboard)
- [Recommendations](#Recommendations)
- [Data Cleaning](#Data-Cleaning)

# Summary 

# Project Goals
### Problem Statement
Which customers should the company prioritize for a targeted marketing campaign to improve customer retention and maximize revenue over the next 6 months?

## The purpose of this project is to identify customers who will provide the highest marginal gain from a marketing campaign 

### Stakeholder Questions
1. Which customers look most likely to churn? 
    * Can we segment them into high, medium, and low retention risk groups?
2. Are there specific products or categories where we’re seeing declining repeat purchases?
    * Which products drive the most revenue from repeat customers versus one-time buyers?
3. How is average revenue per customer trending? Are our top customers maintaining or reducing spend?
    * Can we identify “at-risk” high-value customers (big spenders whose purchases are slowing down)?
4. If we wanted to run a marketing campaign, which exact customers should we prioritize (e.g., those with high revenue but  declining frequency)?
    * Do we know what time window (e.g., 30 days since last purchase) is critical before churn risk spikes?

# Introduction
A retailer company named "Simple Product Co." aims to improve customer retention and increase revenue. To do this, they plan to execute a targeted marketing campaign. Often times, because retaining customers is cheaper than acquiring new ones, they are in need of determining which customers are at highest risk of churning and thus are prime targets. By focusing efforts on the right customers that are most likely to churn, the company can maximize ROI on marketing spend. I hope to use **Tableau** to create a dashboard that helps non-technical stakeholders target key customers and demonstrates monthly customer retention. I will also use **SQL** to validate existing hypotheses and assumptions regarding customer retention to help provide further investigation as to **How the company can increase customer retention**. 

The dataset comes from 
Chen, D. (2015). Online Retail [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5BW33.

# Key Insights
Our dataset includes the company's order history from over **4372 customers** over the **period of 13 months (Dec 2010 - Dec 2011)**. 

**To target Customers**, I targeted and ranked specific customers using <u> Recency, Frequency, and monetary value analysis **(RFM Analysis)**. </u> 
By ranking customers on these 3 metrics, we can determine which percentile of customers are most valuable to target.
The assumptions for RFM Analysis is that:
1. Recent customers are more likely to return.
2. Frequent Buyers tend to be loyal customers
3. High Spenders result in a higher ROI to retain - Useful when targeting not only <u> loyal </u> but also <u> high-value </u> customers

I also quantified the company's overall customer retention using 3 primary metrics:
* Customer Retention Rate (CRR)
* Customer Churn Rate 
* Repeated Purchase Rate (RPR)

# SQL Analysis
By validating the following key hypotheses, I aim to better understand customer behavior.
Understanding the patterns customer behavior helps determine 

H1: Customers who buy multiple product categories are more likely to return.

H2: Customers who make their first purchase in December have lower retention.

H3: The average days between purchases is shorter for loyal customers.

H4: Customers who haven’t purchased in 90+ days are unlikely to return

H5: Customers with only one purchase have a high likelihood of churning

# Dashboard

# Recommendations








<!--Annotations
Table of Contents:
- [Section title](#section-title)


-->