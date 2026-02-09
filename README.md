# Zepto Data Analysis Dashboard 📊

A **data analytics + ML-powered dashboard** built using **Streamlit, PostgreSQL (Neon DB), and Python** to analyze product pricing, discounts, stock availability, and pricing patterns.
This project demonstrates **end-to-end data workflow** — database integration → analysis → visualization → deployment.

---

## 🚀 Live App

👉 [Live App Link](https://sales-data-analysis-cwzwsiv9snkezmxhc3t8vt.streamlit.app/)

---

## 📂 Project Structure

```
Zepto-Data-Analysis/
│
├── app.py                 # Main Streamlit dashboard
├── db_connection.py       # Database connection handler
├── requirements.txt       # Python dependencies
├── README.md              # Project documentation
├── data/
│   └── zepto_raw_csv.csv  # Raw dataset (initial source)
└── Zepto_SQL_Queries.sql  # SQL queries used
```

---

## 📊 Key Features

### Dashboard Analytics

* Product price & discount analysis
* Category-wise pricing insights
* Stock availability overview
* Product distribution visualization

### Database Integration

* PostgreSQL (Neon cloud DB)
* Secure environment variable connection
* Real-time data fetching

### Machine Learning Component

* Basic price prediction model
* Discount vs selling price trend analysis

### Deployment

* Hosted on Streamlit Cloud
* GitHub-based CI deployment

---

## 🛠 Tech Stack

**Frontend / Dashboard**

* Streamlit

**Backend / Data**

* Python
* Pandas
* PostgreSQL (Neon DB)

**Visualization**

* Plotly
* Matplotlib / Streamlit charts

**Deployment**

* Streamlit Community Cloud
* GitHub

---

## ⚙️ Setup Instructions

### 1️⃣ Clone Repository

```bash
git clone https://github.com/Ritesh0802/Sales-Data-Analysis.git
cd Sales-Data-Analysis
```

### 2️⃣ Install Dependencies

```bash
pip install -r requirements.txt
```

### 3️⃣ Configure Database

Create environment variable:

```
DB_URL="your_postgres_connection_string"
```

Example connection format:

```
postgresql://user:password@host/dbname
```

---

### 4️⃣ Run Locally

```bash
streamlit run app.py
```

---

## 💡 Insights Generated

* Discount trends across categories
* Price segmentation patterns
* Inventory availability insights
* Estimated selling price predictions

This helps understand **pricing strategy, stock management, and discount impact**.

---

## 🎯 Future Improvements

* Advanced ML pricing model
* Customer demand forecasting
* Automated data pipeline
* Performance optimization

---

## 👤 Author

**Ritesh Prasad**
Electronics & Communication Graduate
Aspiring Data Analyst / Data Scientist

GitHub: [https://github.com/Ritesh0802](https://github.com/Ritesh0802)

---

⭐ If you found this useful, consider starring the repo.
