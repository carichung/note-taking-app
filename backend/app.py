from flask import Flask, jsonify, request
import psycopg2
import os
import logging
import json
from datetime import datetime
from flask_cors import CORS
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

#-------------------------------------------------------------------------


# ✅ Improved CORS setup
origins = [
    "https://storage.googleapis.com",
    "https://notes.carichung.com",
    "http://127.0.0.1:5500",
    "http://localhost:5500",
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "https://cdn.notes.carichung.com"
] 

CORS(
    app,
    resources={r"/*": {
        "origins": origins,
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }},
    supports_credentials=True
)

#-------------------------------------------------------------------------

# ✅ Optional CORS debug logging
@app.after_request
def log_cors_headers(response):
    app.logger.debug(f"CORS Allow-Origin: {response.headers.get('Access-Control-Allow-Origin')}")
    return response

#-------------------------------------------------------------------------

# ✅ Structured logging setup
class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name
        }
        return json.dumps(log_data)

handler = logging.StreamHandler()
handler.setFormatter(JsonFormatter())
app.logger.setLevel(logging.INFO)
app.logger.addHandler(handler)

#-------------------------------------------------------------------------

# ✅ Database connection
def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=os.environ["DB_HOST"],
            database=os.environ["DB_NAME"],
            user=os.environ["DB_USER"],
            password=os.environ["DB_PASSWORD"]
        )
        app.logger.info("✅ Successfully connected to database")
        return conn
    except Exception as e:
        app.logger.error(f"❌ DB connection failed: {e}")
        raise

#-------------------------------------------------------------------------    

# ✅ Health check route
@app.route("/")
def home():
    app.logger.info("👋 Health check hit")
    return "Flask is connected to PostgreSQL! 🐘✨"

#-------------------------------------------------------------------------

# ✅ Notes endpoint

# @app.route("/notes")
# def get_notes():
#     try:
#         conn = get_db_connection()
#         cursor = conn.cursor()
#         cursor.execute("SELECT title FROM notes")
#         results = cursor.fetchall()
#         conn.close()
#         app.logger.info("📋 Notes fetched successfully")
#         return jsonify([row[0] for row in results])
#     except Exception as e:
#         app.logger.error(f"❌ Error fetching notes: {e}")
#         return jsonify({"error": "Failed to fetch notes"}), 500
    

@app.route("/notes", methods=["GET", "POST"])
def notes():
    if request.method == "GET":
        try:
            conn = get_db_connection()
            cursor = conn.cursor()
            cursor.execute("SELECT title FROM notes")
            results = cursor.fetchall()
            conn.close()
            app.logger.info("📋 Notes fetched successfully")
            return jsonify([row[0] for row in results])
        except Exception as e:
            app.logger.error(f"❌ Error fetching notes: {e}")
            return jsonify({"error": "Failed to fetch notes"}), 500

    elif request.method == "POST":
        try:
            data = request.get_json()
            title = data.get("title", "No title provided")

            # 🔧 FAKE insert for demo
            app.logger.info(f"📝 (FAKE) Note received: {title}")
            return jsonify({"message": f"(FAKE) Note received: {title}"}), 201

        except Exception as e:
            app.logger.error(f"❌ Error in fake POST: {e}")
            return jsonify({"error": "Failed to fake-add note"}), 500




    # # GET fallback
    # try:
    #     conn = get_db_connection()
    #     cursor = conn.cursor()
    #     cursor.execute("SELECT title FROM notes")
    #     results = cursor.fetchall()
    #     conn.close()

    #     app.logger.info("📋 Notes fetched successfully")
    #     return jsonify([row[0] for row in results])
    # except Exception as e:
    #     app.logger.error(f"❌ Error fetching notes: {e}")
    #     return jsonify({"error": "Failed to fetch notes"}), 500

#-------------------------------------------------------------------------

# ✅ Debug endpoint
@app.route("/debug/notes")
def debug_notes():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM notes")
        results = cursor.fetchall()
        conn.close()
        app.logger.debug("🐛 Debug notes fetched")
        return jsonify(results)
    except Exception as e:
        app.logger.error(f"❌ Debug fetch error: {e}")
        return jsonify({"error": "Failed to debug fucking notes"}), 500
    
#-------------------------------------------------------------------------

# ✅ Start the app
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

