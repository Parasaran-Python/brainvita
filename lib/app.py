from flask import Flask, send_file

app = Flask(__name__)

@app.route('/')
def home():
    return send_file('../build/web/index.html')

@app.route('/<path:path>')
def assets(path):
    return send_file('../build/web/'+path)

app.run(host='')