# Customer-Retention-Analysis

# Table of Contents
- [Project Goal](#Project-Goals)
- [Summary](#Summary)
- [Introduction](#Introduction)
- [Key Insights](#Key-Insights)
- [Dashboard](#Dashboard)
- [Dashboard](#Recommendations)
- [Data Cleaning](#Data-Cleaning)

# Project Goals
### Problem Statement
Which customers should the company prioritize for a targeted marketing campaign to improve customer retention and maximize revenue over the next 6 months?


## The purpose of this project is to identify customers who will provide the highest marginal gain from a marketing campaign 

### Stakeholder Questions
1. How should we prioritize customers for marketing campaign?
2. What evidence do we have that certain customer behaviors signal future retention or churn?
3. How can we tell which customers are likely to stop buying from us soon?
4. What characteristics do high-rentention vs. low-retention customers have?
5. Who are our most valuable customers based on their purchasing behavior?

# Summary 

# Introduction
A retailer company named "Simple Product Co." aims to improve customer retention and increase revenue. To do this, they plan to execute a marketing campaign. Often times, because retaining customers is cheaper than acquiring new ones, they are in need of determining which customers are at highest risk of churning and thus are prime targets. By focusing efforts on the right customers that are most likely to churn, the company can maximize ROI on marketing spend. I hope to use **Tableau** to create a dashboard that helps non-technical stakeholders target key customers and demonstrates monthly customer retention. I will also use **SQL** to validate existing hypotheses and assumptions regarding customer retention to help provide further investigation as to **How the company can increase customer retention**. 

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

Page 1 - answers the following questions regarding overall customer retention and churn by visualizing the data:

* How many customers are we losing each month?
    - First, a customer is considered "lost" if they have not purchased in 90+ days. 

* Is churn increasing or decreasing over time?

* What’s our overall churn rate? What’s a "normal" churn rate for our business?

* Are we retaining our most valuable customers or losing them?

* What’s the average time between purchases for retained vs. churned customers?

* Do one-time buyers make up the bulk of our churn?

* What countries (or segments) show the highest churn rates?


Page 2 - Digs deeper and answers the question of "Which customers should we target?"

* Who are our most at-risk customers right now?

* What behaviors do these at-risk customers have in common?

* Are these high-value or low-value customers?

* Can we segment them further (e.g., by geography, recency, or frequency)?

* What retention levers should we consider (discount, loyalty perks, email nudge)?


# Recommendations








<!--Annotations
Table of Contents:
- [Section title](#section-title)


-->