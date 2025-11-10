import argparse
import subprocess
import sys
from pathlib import Path

import pytest

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))
if str(PROJECT_ROOT / "src") not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT / "src"))

from src import generate_file_list as gfl


def make_config(directory: Path, **overrides) -> gfl.GeneratorConfig:
    directory = Path(directory).resolve()
    color = gfl.ColorPreferences(
        source="list",
        colors=["#112233", "#445566"],
        color_range=("#000000", "#FFFFFF"),
        max_attempts=10,
        exclude_dark=False,
        exclude_bright=False,
        exclude_blacks=False,
        exclude_blacks_threshold="#000000",
        ensure_readable=False,
        dark_luminance_threshold=0,
        bright_luminance_threshold=255,
    )
    lazy = gfl.LazyLoadPreferences(
        chunk_size=2,
        viewport_mobile=640,
        viewport_tablet=1024,
        viewport_small_desktop=1366,
        root_margin_mobile="0px 0px 100px 0px",
        root_margin_tablet="0px 0px 200px 0px",
        root_margin_small_desktop="0px 0px 300px 0px",
        root_margin_large_desktop="0px 0px 400px 0px",
    )
    config = gfl.GeneratorConfig(
        directory=directory,
        repo_url="https://example.com/repo",
        fallback_repo_url="https://fallback.example.com/repo",
        link_reference="main",
        output_format="markdown",
        output_file=None,
        header_text="## File List",
        intro_text="Intro",
        repo_root_header="Root",
        categories=[
            gfl.Category(ext=".py", name="Python"),
            gfl.Category(ext=".md", name="Markdown"),
        ],
        ignore_list=list(gfl.DEFAULT_IGNORE_LIST) if hasattr(gfl, "DEFAULT_IGNORE_LIST") else [
            ".git",
            "node_modules",
        ],
        color=color,
        lazy=lazy,
        respect_gitignore=False,
        log_level="INFO",
    )
    for key, value in overrides.items():
        setattr(config, key, value)
    return config


class FakeCompletedProcess:
    def __init__(self, stdout: str = "") -> None:
        self.stdout = stdout


def test_str_to_bool_variants() -> None:
    assert gfl.str_to_bool(True) is True
    assert gfl.str_to_bool("True") is True
    assert gfl.str_to_bool("OFF") is False
    assert gfl.str_to_bool("no") is False
    with pytest.raises(argparse.ArgumentTypeError):
        gfl.str_to_bool("maybe")


def test_render_markdown_groups_files(tmp_path: Path) -> None:
    config = make_config(tmp_path)
    files = [
        Path("main.py"),
        Path("docs/data.csv"),
        Path("notes.txt"),
    ]
    output = gfl.render_markdown(files, config)
    assert "### Python" in output
    assert "- [main.py](https://example.com/repo/blob/main/main.py)" in output
    # Folder without explicit category should create its own heading
    assert "\n### docs\n" in output
    assert "- [docs/data.csv](https://example.com/repo/blob/main/docs/data.csv)" in output
    # Root files remain under the repo root section
    assert "- [notes.txt](https://example.com/repo/blob/main/notes.txt)" in output


def test_render_html_lazyload_chunks(tmp_path: Path) -> None:
    config = make_config(tmp_path, output_format="html")
    config.lazy.chunk_size = 2
    files = [Path(f"file_{idx}.txt") for idx in range(5)]
    html_output = gfl.render_html(files, config)
    assert html_output.count('class="lazyload-placeholder"') == 3
    assert "<script>" in html_output
    assert "file_0.txt" in html_output


def test_build_config_splits_space_delimited_inputs(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("GITHUB_REPOSITORY", "demo/repo")
    monkeypatch.setenv("GITHUB_REF_NAME", "trunk")

    def always_fail(cmd, **kwargs):  # noqa: ANN001
        raise subprocess.CalledProcessError(1, cmd)

    monkeypatch.setattr(gfl.subprocess, "run", always_fail)

    parser = gfl.build_parser()
    args = parser.parse_args(
        [
            "--directory",
            str(tmp_path),
            "--repo-url",
            "",
            "--output-format",
            "markdown",
            "--output-file",
            "out.md",
            "--color-source",
            "list",
            "--color-list",
            "#111111 #222222",
            "--file-categories",
            ".txt Text .rst ReStructured",
            "--ignore-list",
            "build dist",
            "--respect-gitignore",
            "true",
            "--log-level",
            "DEBUG",
        ]
    )

    config = gfl.build_config(args)

    assert config.color.colors == ["#111111", "#222222"]
    assert any(category.ext == ".txt" for category in config.categories)
    assert {
        "build",
        "dist",
    }.issubset(set(config.ignore_list))
    assert config.respect_gitignore is True
    assert config.output_file == (tmp_path / "out.md").resolve()
    assert config.repo_url == "https://github.com/demo/repo"
    assert config.link_reference == "trunk"


def test_collect_files_prefers_git_when_available(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    repo_dir = tmp_path / "repo"
    repo_dir.mkdir()
    config = make_config(repo_dir, respect_gitignore=True)
    config.ignore_list = ["ignored"]

    def fake_run(cmd, **kwargs):  # noqa: ANN001
        if cmd[:3] == ["git", "rev-parse", "--show-toplevel"]:
            return FakeCompletedProcess(stdout=str(repo_dir))
        if cmd[:2] == ["git", "ls-files"]:
            return FakeCompletedProcess(stdout="keep.txt\nignored/file.txt\n")
        raise subprocess.CalledProcessError(1, cmd)

    monkeypatch.setattr(gfl.subprocess, "run", fake_run)

    files = gfl.collect_files(config)
    assert files == [Path("keep.txt")]


def test_collect_files_falls_back_to_os(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    repo_dir = tmp_path / "repo"
    repo_dir.mkdir()
    (repo_dir / "root.txt").write_text("root", encoding="utf-8")
    kept_dir = repo_dir / "kept"
    kept_dir.mkdir()
    (kept_dir / "keep.txt").write_text("keep", encoding="utf-8")
    ignored_dir = repo_dir / "ignored"
    ignored_dir.mkdir()
    (ignored_dir / "skip.txt").write_text("skip", encoding="utf-8")

    config = make_config(repo_dir, respect_gitignore=True)
    config.ignore_list = config.ignore_list + ["ignored"]

    def failing_run(cmd, **kwargs):  # noqa: ANN001
        raise subprocess.CalledProcessError(1, cmd)

    monkeypatch.setattr(gfl.subprocess, "run", failing_run)

    files = gfl.collect_files(config)
    assert set(files) == {Path("kept/keep.txt"), Path("root.txt")}
