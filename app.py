import streamlit as st
import pandas as pd
import plotly.express as px
from db_connection import get_connection

# Title
st.title("Zepto Data Dashboard")

# DB connection
conn = get_connection()
df = pd.read_sql("SELECT * FROM zepto;", conn)

df.rename(columns={
    "discountpercent": "discount_percent",
    "discountedsellingprice": "discounted_selling_price",
    "weightingms": "weight_g"
}, inplace=True)

# Raw data expander
with st.expander("View Raw Data"):
    st.dataframe(df)

# KPIs
col1, col2 = st.columns(2)
col1.metric("Total Products", len(df))
col2.metric("Avg Discount %", round(df["discount_percent"].mean(), 2))

# Category filter (IMPORTANT — before charts)
category = st.selectbox("Category", sorted(df["category"].unique()))
filtered_df = df[df["category"] == category]

# -------- PRICE CHART --------
st.subheader("Average Price by Category")
cat_avg = df.groupby("category")["discounted_selling_price"].mean()
st.bar_chart(cat_avg)

avg_price = filtered_df["discounted_selling_price"].mean()
st.markdown(
    f"**Insight:** Average selling price in **{category}** "
    f"is around ₹{avg_price:.0f}, indicating its pricing level "
    f"relative to other categories."
)

# -------- DISCOUNT CHART --------
st.subheader("Average Discount by Category")
disc_avg = df.groupby("category")["discount_percent"].mean()
st.bar_chart(disc_avg)

avg_disc = filtered_df["discount_percent"].mean()
st.markdown(
    f"**Insight:** Products in **{category}** have an average "
    f"discount of about {avg_disc:.1f}%, showing promotional "
    f"activity in this segment."
)

# -------- STOCK INSIGHT --------
stock_pct = (filtered_df["available_quantity"] > 0).mean() * 100
st.markdown(
    f"**Stock Insight:** About {stock_pct:.1f}% of items in "
    f"**{category}** are currently in stock."
)

# -------- PRICE VS DISCOUNT RELATIONSHIP --------
st.subheader("Price vs Discount Relationship")

# Category filter specifically for scatter chart
selected_cat = st.multiselect(
    "Filter Categories for Scatter Chart",
    df["category"].unique(),
    default=df["category"].unique()[:5]
)

filtered_scatter = df[df["category"].isin(selected_cat)]

# Scatter chart
fig = px.scatter(
    filtered_scatter,
    x="discount_percent",
    y="discounted_selling_price",
    color="category",
    opacity=0.5
)

st.plotly_chart(fig, use_container_width=True)

st.markdown(
    "**Insight:** Higher discounts don’t always reduce selling price. "
    "Premium product categories still maintain higher pricing despite discounts."
)


# -------- PRODUCT COUNT BY CATEGORY --------
st.subheader("Product Distribution by Category")

cat_count = df["category"].value_counts()
st.bar_chart(cat_count)

st.markdown(
    "**Insight:** Categories with more products indicate stronger "
    "inventory focus or higher demand segments."
)

# -------- STOCK AVAILABILITY --------
st.subheader("Stock Availability Overview")

stock_status = df["available_quantity"].apply(
    lambda x: "In Stock" if x > 0 else "Out of Stock"
).value_counts()

st.bar_chart(stock_status)

st.markdown(
    "**Insight:** A higher proportion of in-stock products suggests "
    "healthy inventory levels, while frequent stock-outs may impact "
    "customer satisfaction."
)


# -------- DISCOUNT RECOMMENDATION --------
st.subheader("Recommended Discount Range")

rec_disc = df.groupby("category")["discount_percent"].mean()

category_choice = st.selectbox(
    "Select Category for Discount Insight",
    rec_disc.index
)

st.success(
    f"Typical discount in {category_choice}: "
    f"~{rec_disc[category_choice]:.1f}%"
)

st.caption(
    "This shows average discount patterns in the dataset. "
    "Helps understand competitive pricing trends."
)


