import logging
import asyncio
from aiochris import ChrisClient
from aiochris.errors import IncorrectLoginError

ADDRESS = 'http://localhost:32000/api/v1/'
USERNAME = 'testuser'
PASSWORD = 'testuser1234'
plugin_name = 'pl-mri10yr06mo01da_normal'

logging.basicConfig(level=logging.INFO)


async def main():
    chris = await get_client()
    plugin = await chris.search_plugins(name_exact=plugin_name).get_only(allow_multiple=True)
    logging.info(f'Found plugin {plugin_name} id={plugin.id}')
    plinst = await plugin.create_instance()
    logging.info(f'Created plugin instance id={plinst.id}')
    elapsed, finished_plugin = await plinst.wait()
    logging.info(f'Finished after {elapsed:.2f}s, status={finished_plugin.status}')
    await chris.close()


async def get_client():
    try:
        return await ChrisClient.from_login(ADDRESS, USERNAME, PASSWORD)
    except IncorrectLoginError:
        user = await ChrisClient.create_user(ADDRESS, USERNAME, PASSWORD, f'{USERNAME}@example.org')
        logging.info(f'Created user {user.username}, id={user.id}')
        return await ChrisClient.from_login(ADDRESS, USERNAME, PASSWORD)


if __name__ == '__main__':
    asyncio.run(main())
