from __future__ import annotations

import subprocess
import sys
import unittest
from pathlib import Path


class BucketSortDemoTest(unittest.TestCase):
    def test_demo_script_exits_successfully(self) -> None:
        script = Path(__file__).with_name("bucket_sort_demo.py")
        result = subprocess.run(
            [sys.executable, str(script)],
            capture_output=True,
            text=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, msg=result.stderr or result.stdout)
        self.assertIn("Validation: PASS", result.stdout)


if __name__ == "__main__":
    unittest.main()
