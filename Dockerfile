FROM python:3.10 AS builder

RUN python -m pip install --upgrade pip  && \
    python -m pip install --upgrade build

WORKDIR /app

COPY requirements.txt .

RUN pip install --user -r requirements.txt

COPY . .

RUN python -m build

FROM python:3.10-slim

RUN python -m pip install --upgrade pip

COPY --from=builder /app/dist/cloudflare_security_group_updater-*.whl /
COPY --from=builder /root/.local /root/.local

RUN python -m pip install cloudflare_security_group_updater-*.whl

RUN rm cloudflare_security_group_updater-*.whl

CMD [ "cloudflare-security-group-updater" ]
