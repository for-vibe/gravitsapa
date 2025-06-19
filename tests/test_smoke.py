import os


def test_main_scene_exists():
    assert os.path.isfile("Main.tscn")


def test_project_main_scene_path():
    with open("project.godot", "r", encoding="utf-8") as f:
        content = f.read()
    assert 'run/main_scene="res://Main.tscn"' in content
