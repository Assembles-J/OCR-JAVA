import os
from flask import Flask, request, jsonify
from paddleocr import PaddleOCR
import traceback
from paddlenlp import Taskflow

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

app = Flask(__name__)
# enable_mkldnn=False  这里地方需要关闭 ，官方 issue https://github.com/PaddlePaddle/PaddleOCR/issues/7990
ocr = PaddleOCR(enable_mkldnn=False ,use_angle_cls=True, det_model_dir=SCRIPT_DIR,lang="ch")

# 进行OCR 文字识别
@app.route('/ocr', methods=['POST'])
def perform_ocr_endpoint():
    try:
#         https://github.com/PaddlePaddle/PaddleOCR/issues/8153 CPU推理，开启mkldnn报错 ,每次使用的时候都新建对象
        ocr = PaddleOCR(use_angle_cls=True, det_model_dir=SCRIPT_DIR,lang="ch")

    # 解析 JSON 请求体


        data = request.get_json()

        # 获取 JSON 数据中的参数
        file_path = data.get('path')
        schema = data.get('schema')

        if 'source' in request.files:
            file = request.files['source']
            image_path = save_file_temporarily(file)
            results = perform_ocr(image_path)
            return jsonify(results)
        elif file_path:
#             schema=request.args.get('schema')
#             schema=request.form.get('schema')
            print(schema)
            # image_path = request.args['path']
            image_path = file_path


            results = perform_ocr(image_path)

            text_list = []
            for re in results:
                text_list.append(re.get("text", ""))

            text = "".join(text_list)

            if schema is not None and len(schema) > 0:

                re = info_extraction(schema,text)
                return jsonify(re)

            return jsonify(results)
        else:
            return jsonify({'error': 'Missing parameters'}), 400
    except Exception as e:
        # 捕获并记录详细的异常信息
        error_message = traceback.format_exc()
        app.logger.error("Error occurred: %s", error_message)
        return jsonify({'error': str(e), 'trace': error_message}), 500



@app.route('/infoExtract', methods=['POST'])
def ocr_info_extract():

    try:
        if 'path' in request.args:

            # schema 表示用于 处理数据的对象
            schema=request.args.get('schema')

            ocr = PaddleOCR(use_angle_cls=True, det_model_dir=SCRIPT_DIR,lang="ch")

            image_path = request.args['path']
#             输出文本
            results = perform_ocr(image_path)
#             文本特征识别
            outPutList = info_extraction(schema,image_path)

            return jsonify(outPutList)
        else:
            return jsonify({'error': 'Missing parameters'}), 400
    except Exception as e:
        # 捕获并记录详细的异常信息
        error_message = traceback.format_exc()
        app.logger.error("Error occurred: %s", error_message)
        return jsonify({'error': str(e), 'trace': error_message}), 500

def info_extraction(schema,text):
    ie = Taskflow('information_extraction', schema=schema)

    res = ie(text)

    outPutList = []
    for key, value in res[0].items():
        outPutList.append({"key": key, "text": value[0].get('text',"")})

    return outPutList


def perform_ocr(image_path):
    try:
        ocr_results = ocr.ocr(image_path, cls=True)
        results = []
        for result in ocr_results:
            for index, re in enumerate(result):
                text = re[1][0]
                confidence = re[1][1]
                results.append({"index": index, "text": text, "confidence": confidence})
        return results
    except Exception as e:
        raise RuntimeError(f"OCR processing failed: {str(e)}")

def save_file_temporarily(file):
    temp_file = './tmp/uploaded_image.png'  # Example path for Linux, adjust as needed
    file.save(temp_file)
    return temp_file

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
