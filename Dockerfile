FROM python:alpine
COPY . /app
WORKDIR /app
RUN pip install -f requirements.ext
EXPOSE 80
CMD python ./bookstore-api.py