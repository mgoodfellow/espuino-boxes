"""Exercise deployment boundaries with temporary Git repositories and a fake pio.
No hardware, network access or installed PlatformIO is used.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'deploy.sh'


class DeployTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='espuino-deploy-test-')
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.repo = self.root / 'profiles'
        self.box = self.repo / 'boxes' / 'test-box'
        self.box.mkdir(parents=True)
        shutil.copyfile(SCRIPT, self.repo / 'deploy.sh')
        (self.box / 'box.conf').write_text('ENV=test-env\n')
        (self.box / 'platformio-override.ini').write_text('[env:test-env]\n')
        (self.box / 'settings-override.h').write_text('// test settings\n')
        (self.box / 'sdkconfig.defaults.esp32s3').write_text('CONFIG_SPIRAM_MODE_OCT=y\n')
        self.firmware = self.root / 'firmware'
        (self.firmware / 'src').mkdir(parents=True)
        self.git('init', '-q')
        self.git('config', 'user.name', 'Test')
        self.git('config', 'user.email', 'test@example.invalid')
        (self.firmware / 'tracked').write_text('original\n')
        self.git('add', '.')
        self.git('commit', '-qm', 'fixture')
        (self.box / 'upstream.lock').write_text(self.git('rev-parse', 'HEAD').stdout)
        self.pio = self.root / 'pio'
        self.pio.write_text('''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
p=Path(os.environ['FAKE_LOG'])
with p.open('a') as f: f.write(json.dumps(sys.argv[1:])+'\\n')
if '-t' not in sys.argv:
    calls=len(p.read_text().splitlines())
    mode=os.environ.get('FAKE_MODE','ok')
    content='CONFIG_SPIRAM_MODE_OCT=y\\n'
    if mode=='always-drop' or (mode=='drop-once' and calls==1): content=''
    Path('sdkconfig.test-env').write_text(content)
''')
        self.pio.chmod(0o755)
        self.log = self.root / 'calls.jsonl'
        self.env = dict(os.environ, ESPUINO_DIR=str(self.firmware),
                        PIO=str(self.pio), FAKE_LOG=str(self.log))

    def git(self, *args):
        return subprocess.run(['git', '-C', str(self.firmware), *args],
                              check=True, text=True, capture_output=True)

    def run_deploy(self, *args):
        return subprocess.run(['bash', str(self.repo / 'deploy.sh'), 'test-box', *args],
                              env=self.env, capture_output=True, text=True)

    def calls(self):
        import json
        return [json.loads(x) for x in self.log.read_text().splitlines()] if self.log.exists() else []

    def test_upload_requires_port_before_build_or_copy(self):
        result = self.run_deploy('upload')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('explicit port', result.stderr)
        self.assertEqual(self.calls(), [])
        self.assertFalse((self.firmware / 'platformio-override.ini').exists())

    def test_explicit_upload_port_is_passed_as_one_argument(self):
        result = self.run_deploy('upload', '/dev/example port')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.calls()[-1], ['run', '-e', 'test-env', '-t', 'upload',
                                          '--upload-port', '/dev/example port'])

    def test_sdkconfig_dropped_once_is_restored_before_upload(self):
        self.env['FAKE_MODE'] = 'drop-once'
        result = self.run_deploy('upload', '/dev/example')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(len(self.calls()), 3)
        self.assertEqual((self.firmware / 'sdkconfig.test-env').read_text(),
                         'CONFIG_SPIRAM_MODE_OCT=y\n')

    def test_persistently_missing_sdkconfig_prevents_upload(self):
        self.env['FAKE_MODE'] = 'always-drop'
        result = self.run_deploy('upload', '/dev/example')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(self.calls()), 2)
        self.assertTrue(all('upload' not in c for c in self.calls()))

    def test_sync_rejects_staged_changes_without_changing_head(self):
        head = self.git('rev-parse', 'HEAD').stdout
        (self.firmware / 'tracked').write_text('staged edit\n')
        self.git('add', 'tracked')
        result = self.run_deploy('sync')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('uncommitted changes', result.stderr)
        self.assertEqual(self.git('rev-parse', 'HEAD').stdout, head)
        self.assertEqual((self.firmware / 'tracked').read_text(), 'staged edit\n')

    def test_sync_allows_clean_checkout(self):
        result = self.run_deploy('sync')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == '__main__':
    unittest.main()
