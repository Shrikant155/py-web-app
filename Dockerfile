FROM python:3.9-slim as Builder
WORKDIR /app
COPY requirements.txt  .
RUN pip install   --no-cache-dir  --user -r requirements.txt 

FROM python:3.9-slim
WORKDIR /app
COPY --from=Builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
EXPOSE 5000
ENTRYPOINT ["python"]
CMD ["app.py"]
