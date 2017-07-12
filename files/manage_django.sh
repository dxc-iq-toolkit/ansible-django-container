#!/bin/bash

# Run django management command

cd ${DJANGO_ROOT}/${PROJECT_NAME}
source ${DJANGO_VENV}/bin/activate
${DJANGO_VENV}/bin/python ./manage.py "$@"