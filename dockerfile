FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ .
RUN apt-get update && apt-get install -y wget
RUN mkdir src
RUN wget https://github.com/Nick2bad4u/generate-repo-file-list/raw/refs/heads/main/src/generate_file_list.py -O src/generate_file_list.py
ENTRYPOINT ["python", "src/generate_file_list.py"]