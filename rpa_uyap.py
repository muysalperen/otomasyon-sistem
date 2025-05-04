import os
from docxtpl import DocxTemplate

def generate_pdf(data):
    tpl = DocxTemplate("template.udf")
    tpl.render(data)
    out="output.docx"
    tpl.save(out)
    os.system(f"libreoffice --headless --convert-to pdf {out}")

if __name__=="__main__":
    print("RPA modülü hazır.")
