import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Load transactional data
df = pd.read_csv('data/customer_sales_and_churn.csv')

print("="*60)
print("EXECUTIVE DATA SUMMARY:")
print(f"Total Transactions: {len(df)}")
print(f"Unique Customers: {df['customer_id'].nunique()}")
print(f"Total Portfolio MRR: ${df['mrr_usd'].sum():,.2f}")
print(f"Overall Churn Rate: {df['is_churned'].mean() * 100:.2f}%")
print("="*60)

# Churn correlation analysis
numeric_cols = ['mrr_usd', 'contract_term_months', 'csat_score', 'support_tickets_90d', 'is_churned']
corr = df[numeric_cols].corr()
print("\nCorrelation with Churn:")
print(corr['is_churned'].sort_values(ascending=False))

# Segment-level metrics
summary = df.groupby('segment').agg({
    'customer_id': 'count',
    'mrr_usd': ['sum', 'mean'],
    'is_churned': 'mean',
    'csat_score': 'mean'
}).reset_index()
summary.columns = ['Segment', 'Accounts', 'Total MRR ($)', 'Avg MRR ($)', 'Churn Rate', 'Avg CSAT']
summary['Churn Rate'] = (summary['Churn Rate'] * 100).round(2).astype(str) + '%'
summary['Avg CSAT'] = summary['Avg CSAT'].round(2)
print("\nSegment Performance Summary:")
print(summary.to_string(index=False))
