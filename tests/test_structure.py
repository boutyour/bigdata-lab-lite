from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_core_files_exist():
    required = [
        "compose.yaml",
        "Makefile",
        "profiles/8gb.yaml",
        "profiles/16gb.yaml",
        "profiles/plus.yaml",
        "docker/runtime/Dockerfile",
        "docker/runtime/hadoop/entrypoint.sh",
        "docker/runtime/hadoop/config/core-site.xml",
        "docker/hive-postgres/Dockerfile",
        "docker/hive/conf/core-site.xml",
        "docker/hive/conf/hive-site.xml",
        "docs/OPTIMISATION.md",
        "docs/TP-06-Hive.md",
        "docs/TP-07-Hive-Spark.md",
        "tp/06-hive/tp06.sql",
        "tp/07-hive-spark/read_hive_parquet.py",
        "scripts/test-hive.sh",
        "scripts/test-hive-spark.sh",
        "scripts/benchmark-images.sh",
        "scripts/static-smoke.sh",
    ]
    missing = [p for p in required if not (ROOT / p).exists()]
    assert not missing, f"Missing files: {missing}"


def test_compose_targets_and_hive_profiles():
    text = (ROOT / "compose.yaml").read_text()
    for token in ["hive-lite:", "postgres:", "metastore:", "hive-full:"]:
        assert token in text
    assert "target: hadoop" in text
    assert "target: spark" in text
    assert "image: apache/hive:4.2.1" in text
    assert "image: bigdata-lab/hive-postgres:4.2.1" in text


def test_runtime_dockerfile_is_conservative_multistage():
    text = (ROOT / "docker/runtime/Dockerfile").read_text()
    for stage in ["AS hadoop-fetch", "AS java11-runtime", "AS hadoop", "AS spark-fetch", "AS java17-python-runtime", "AS spark"]:
        assert stage in text
    assert "hadoop-${HADOOP_VERSION}-lean.tar.gz" in text
    assert "spark-${SPARK_VERSION}-bin-hadoop3" in text
    assert "sha512sum -c" in text
    # Guardrail: no explicit deletion of framework JARs.
    assert "rm -rf /opt/hadoop/share" not in text
    assert "rm -rf /opt/spark/jars" not in text


def test_makefile_has_build_and_hive_targets():
    text = (ROOT / "Makefile").read_text()
    for target in [
        "build-hadoop:", "build-spark:", "build-hive:", "benchmark-images:", "smoke:",
        "hive-up:", "hive-shell:", "hive-test:", "hive-spark-up:", "hive-spark-test:"
    ]:
        assert target in text


def test_8gb_profile_is_bounded():
    text = (ROOT / "profiles/8gb.yaml").read_text()
    assert "3000m" in text
    assert "2800m" in text
    assert "1200m" in text
