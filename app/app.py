import streamlit as st
import pandas as pd
import joblib
import os
import warnings

# Terminaldeki o can sıkıcı "FutureWarning" mesajlarını susturuyoruz
warnings.filterwarnings("ignore")

import google.generativeai as genai

# 1. Page Configuration
st.set_page_config(
    page_title="Sales Forecasting and Analysis",
    page_icon="📈",
    layout="wide"
)

# 2. API ve Model Kurulumu (Güncel ve Kararlı Sürüm)
try:
    genai.configure(api_key=st.secrets["GEMINI_API_KEY"])
    # En güncel desteklenen model tanımı
    gemini_model = genai.GenerativeModel('gemini-3.6-flash')
    api_ready = True
except Exception as e:
    api_ready = False
    st.warning("Gemini API key not configured properly.")

# Model Yükleme
current_dir = os.path.dirname(os.path.abspath(__file__))
model_path = os.path.join(current_dir, '..', 'models', 'rf_sales_model.joblib')

@st.cache_resource
def load_model():
    return joblib.load(model_path)

try:
    model = load_model()
    model_loaded = True
except Exception as e:
    model_loaded = False
    st.error(f"Model could not be loaded! Error: {e}")

# 3. Main Title
st.title("🚀 Smart Sales Forecasting and Analysis System")
st.markdown("This web application predicts future sales using historical sales data and a **Random Forest** machine learning model.")
st.divider()

# 4. Sidebar Design
st.sidebar.header("🎛️ Forecast Parameters")
st.sidebar.markdown("Adjust the values below to forecast for the upcoming month:")

selected_year = st.sidebar.number_input("Select Year", min_value=2014, max_value=2030, value=2014, step=1)
selected_month = st.sidebar.slider("Select Month (1-12)", min_value=1, max_value=12, value=2)
prev_month_sales = st.sidebar.number_input("Previous Month's Sales Amount ($)", min_value=0.0, value=1500000.0, step=50000.0)

# 5. Prediction Logic & Dashboard Layout
if st.button("🔮 Predict Sales", use_container_width=True):
    if model_loaded:
        input_data = pd.DataFrame({
            'Year': [selected_year],
            'Month': [selected_month],
            'Prev_Month_Sales': [prev_month_sales]
        })
        
        input_data = input_data[model.feature_names_in_]
        
        with st.spinner("Calculating forecast..."):
            prediction = model.predict(input_data)
            predicted_value = prediction[0]
            
            st.success("Forecast completed successfully!")
            
            col1, col2 = st.columns(2)
            
            with col1:
                if prev_month_sales > 0:
                    percent_change = ((predicted_value - prev_month_sales) / prev_month_sales) * 100
                else:
                    percent_change = 0.0

                st.metric(
                    label=f"Predicted Sales ({selected_year}-{selected_month:02d})", 
                    value=f"${predicted_value:,.2f}",
                    delta=f"{percent_change:.1f}% vs Previous Month"
                )
                
            with col2:
                chart_data = pd.DataFrame(
                    [prev_month_sales, predicted_value], 
                    index=["Previous Month", "Predicted Month"],
                    columns=["Sales ($)"]
                )
                st.bar_chart(chart_data)

            # --- YAPAY ZEKA (GEMINI) YORUMU ---
            st.subheader("🧠 AI Executive Summary")
            if api_ready:
                with st.spinner("Generating AI insights..."):
                    prompt = f"""
                    You are a senior data analyst and strategic advisor. We have a sales forecast for {selected_year}-{selected_month:02d}.
                    Previous month's sales were ${prev_month_sales:,.2f}.
                    The forecasted sales are ${predicted_value:,.2f}, which represents a {percent_change:.1f}% change.
                    Provide a professional, 2-3 sentence executive summary explaining this trend.
                    Keep it concise, strictly business-focused, write in English. Do NOT use markdown bold or italic asterisks.
                    """
                    try:
                        response = gemini_model.generate_content(prompt)
                        # st.info yerine st.markdown kullanarak metin içi kalın (bold) yazımları aktif ediyoruz
                        st.markdown(response.text)
                    except Exception as e:
                        st.error(f"AI generating failed: {e}")
            else:
                st.warning("Please configure your API key to see AI insights.")
                
    else:
        st.error("Cannot make predictions because the model is not loaded.")