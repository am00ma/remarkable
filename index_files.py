from os import link, mkdir
from pathlib import Path
from dataclasses import dataclass

import pandas as pd

from helpers import load_json, save_db


@dataclass()
class DirNode:
    name: str
    uuid: str
    type: str
    children: list[DirNode]


def index_node(n: DirNode, df: pd.DataFrame, data: dict[str, DirNode]):
    for _, r in df[df.parent == n.uuid].iterrows():
        child = DirNode(r.visibleName, r.uuid, r.type, [])
        data[r.uuid] = child
        n.children.append(child)
        index_node(child, df, data)


def create_dirs(n: DirNode, path: Path):
    if n.type != "CollectionType":
        return
    path = path / n.name
    if not path.exists():
        mkdir(path)
    for child in n.children:
        create_dirs(child, path)


def copy_documents(n: DirNode, path: Path, src_dir: Path):
    if n.type == "DocumentType":
        dst_path = path / f"{n.name}.pdf"
        src_path = src_dir / "files" / f"{n.uuid}.pdf"

        # Need to render to pdf using rmc
        if not src_path.exists():
            print(dst_path, src_path)

        if (not dst_path.exists()) & src_path.exists():
            link(src_path, dst_path)

        src_path = src_dir / "files" / n.uuid
        dst_path = path / "rm"
        if (not dst_path.exists()) & src_path.exists():
            dst_path.mkdir(parents=True)
            for f in src_path.iterdir():
                if not (dst_path / f.name).exists():
                    link(src_path / f.name, dst_path / f.name)

    elif n.type == "TemplateType":
        dst_path = path / f"{n.name}.pdf"
        src_path = src_dir / "files" / f"{n.uuid}.pdf"

        if (not dst_path.exists()) & src_path.exists():
            link(src_path, dst_path)

        src_path = src_dir / "files" / n.uuid
        dst_path = path / "rm"
        if (not dst_path.exists()) & src_path.exists():
            dst_path.mkdir(parents=True)
            for f in src_path.iterdir():
                if not (dst_path / f.name).exists():
                    link(src_path / f.name, dst_path / f.name)

    elif n.type == "CollectionType":
        path = path / n.name
        for child in n.children:
            copy_documents(child, path, src_dir)


if __name__ == "__main__":

    src_dir = Path("./ssh-data")
    dst_dir = Path("./data")

    rows = []
    for f in src_dir.glob("**/*.metadata"):
        rows.append({**load_json(f), "uuid": f.stem})
    df = pd.DataFrame(rows)
    save_db(df, dst_dir / "files.db", "metadata", verbose=True)

    data = {}
    root = DirNode("files", "", "CollectionType", [])
    index_node(root, df, data)

    create_dirs(root, dst_dir)

    copy_documents(root, dst_dir, src_dir)
