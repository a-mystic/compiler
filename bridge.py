import subprocess
from flask import Flask, jsonify, request

app = Flask(__name__)

def makeTextFile(command: str):
    if command == 'none':
        print("none")
        return "need comamnd"
    else:
        f = open("your path\\inputFromiOS.txt", 'w', encoding='utf-8')
        f.write(command)
        f.close()   

def compileRun() -> str:
    result = subprocess.run(
        'your path\\cbu.exe',
        shell=True,
        capture_output=True,
        input=False,
        encoding='utf-8',
    )
    return result.stdout

def stackSimRun():
    Stackresult = subprocess.run(
        'your path\\StackSim.exe your path\\a.asm',
        shell=True,
        capture_output=True,
        input=False,
        encoding='cp949',
    )
    return Stackresult.stdout

@app.route('/')
def home():
    receiveCommand = request.args.get('command', 'none')
    print
    makeTextFile(command=receiveCommand)
    data = {
        'compileResult' : str(compileRun()),
        'stackSimResult' : str(stackSimRun())
        }
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
