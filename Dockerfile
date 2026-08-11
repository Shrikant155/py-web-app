FROM python:3.14-slim AS builder
WORKDIR /app
COPY requirements.txt  .
RUN pip install   --no-cache-dir  --user -r requirements.txt 

FROM python:3.14-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local

RUN pip install --no-cache-dir --user --upgrade  setuptools>=78.1.1 msgpack>=1.2.1
COPY . . 
ENV PATH=/root/.local/bin:$PATH
EXPOSE 5000
ENTRYPOINT ["python"]
CMD ["app.py"]
