#!/bin/bash -ex

exec kubectl exec -it -n kk deploy/cacao-chris-server -- sh -exc '
python -m venv /tmp/venv
/tmp/venv/bin/pip install tqdm
export PYTHONPATH=/opt/app-root/lib/python3.11/site-packages:/tmp/venv/lib/python3.11/site-packages
python manage.py shell -c "
from django.conf import settings
from core.storage import connect_storage
from pacsfiles.models import PACSFile
from tqdm.contrib.concurrent import thread_map

for _ in thread_map(lambda p: p.delete(), PACSFile.objects.all()):
    pass

storage = connect_storage(settings)
for _ in thread_map(storage.delete_obj, storage.ls(\"SERVICES/PACS\")):
    pass
"
'
