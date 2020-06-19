FROM python:3.8.3-alpine3.12

WORKDIR /app

COPY ./src /app

RUN adduser -D app && \
    pip install -r requirements.txt

USER app

ENTRYPOINT ["python3", "app.py"]