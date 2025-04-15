# Use an official Python image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

COPY requirements.txt .     
RUN pip install -r requirements.txt


# ✅ Install required libraries
RUN pip install flask psycopg2-binary


# Copy source code
COPY app.py .

# Install Flask
RUN pip install flask

# Expose port
EXPOSE 5000


# Run the app
CMD ["python", "app.py"]
