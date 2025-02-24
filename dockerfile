FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
COPY src/ .
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt

ENTRYPOINT ["python", "src/generate_file_list.py"]