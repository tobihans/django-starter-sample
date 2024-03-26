FROM python:3.11.6-slim-bullseye as python-slim-bullseye

ENV P1="pip3 download --cache-dir . --only-binary=:all"
ENV P2="pip3 install --find-links=. --cache-dir . --disable-pip-version-check"

# Export pyproject.toml to requirements.txt
COPY pyproject.toml poetry.lock ./
RUN python3 -m pip install --user -U pipx && \
    python3 -m pipx run poetry export --with dev -o requirements.txt --without-hashes

# Install dependencies and remove cache
RUN pip3 install -U pip setuptools wheel && \
    $P1 -r requirements.txt && $P2 $(ls *.gz | tr '\n' ' ') && $P2 $(ls *.whl | tr '\n' ' ') && \
    find /usr/local/lib/python* -name '__pycache__' -type d -print0 | xargs -0 /bin/rm -rf '{}' && \
    find /usr/local/lib/python* -iname '*.pyc' -delete

FROM python:3.11.6-slim-bullseye

COPY --from=python-slim-bullseye /usr/local/bin /usr/local/bin
COPY --from=python-slim-bullseye /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=python-slim-bullseye /root/.local/lib/python3.11/site-packages /root/.local/lib/python3.11/site-packages

# NOTE: Disable this to include source code.
# If you do so, make sure you're not mounting 
# the code as a volume.
# COPY . /app

ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

CMD [ "gunicorn", "-c", "conf/gunicorn.conf.py" ]
