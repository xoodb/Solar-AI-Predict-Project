FROM python:3.11.8

WORKDIR /CODE

COPY . .

RUN apt-get update && apt-get install -y tzdata

ENV TZ=Asia/Seoul

RUN pip install -r requirements.txt

ENTRYPOINT ["python"]

CMD ["persistent_update/total_run.py"]