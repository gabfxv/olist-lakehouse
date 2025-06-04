FROM python:3.10-slim

WORKDIR /usr/app

COPY . /usr/app

RUN pip install -r requirements.txt

EXPOSE 8081

CMD ["dbt", "docs", "serve", "--port", "8081", "--host", "0.0.0.0"]