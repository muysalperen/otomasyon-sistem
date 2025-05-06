# orchestrator.py

import time
import json
import ingestion
import download_evidence
import classification
import screenshot
import rpa_uyap

def run_pipeline():
    # 1) İçerik Toplama
    ingestion.ingest_posts()
    # 2) Kanıt İndirme
    download_evidence.download_evidence()
    # 3) Sınıflandırma & Onaylama
    data = json.load(open("posts.json"))['data']
    approved = []
    for p in data:
        cats = classification.classify_text(p.get('caption',''))
        if not any(cats.get(c) for c in ['hate','violence']):
            approved.append(p)
    json.dump({'data': approved}, open("approved_data.json","w"))
    # 4) Ekran Görüntüleri
    screenshot.take_screenshots()
    # 5) RPA → UYAP
    if approved:
        rpa_uyap.generate_pdf({
            'USERNAME':'Ad Soyad',
            'DATE':time.strftime("%Y-%m-%d"),
            'COMMENT':'Onaylanan içerik',
            'EVIDENCE_URL':'https://example.com/evidence'
        })

if __name__=="__main__":
    while True:
        try:
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Pipeline başladı.", flush=True)
            run_pipeline()
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Pipeline tamamlandı. 1 saat sonra tekrar çalışacak.", flush=True)
            time.sleep(3600)
        except Exception as e:
            print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Hata yakalandı: {e}", flush=True)
            # Hatanın detayını traceback olarak yazmak istersen:
            import traceback; traceback.print_exc()
            # 1 dakika bekleyip yeniden dene
            time.sleep(60)
