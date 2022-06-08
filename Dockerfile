FROM python:3.9.7 as builder

ENV PYTHONUNBUFFERED True

RUN apt update && apt install -y gcc g++ libffi-dev libc-dev make libsqlite3-dev git perl \
    && git clone --recursive https://github.com/epoz/fts5-snowball.git

WORKDIR /fts5-snowball
RUN make

FROM python:3.9.7

COPY --from=builder /fts5-snowball/fts5stemmer.so /usr/local/lib/

RUN mkdir -p /app
ENV HOME=/app

WORKDIR $HOME

RUN pip install --upgrade pip
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src .

CMD ["uvicorn", "--host", "0.0.0.0", "--port", "8000", "app:app", "--log-level", "debug" ]
