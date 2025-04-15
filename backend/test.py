from flask import Flask, jsonify

app = Flask(__name__)

with app.app_context():
    print(jsonify(["Note 1", "Note 2", "Note 3", "Note 4", "Note 5", "Note 6"]).get_data(as_text=True))
