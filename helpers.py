from typing import Literal
from pathlib import Path

import json
import sqlite3
import pandas as pd

JSONType = dict[str, str | int | float | Path]


def save_json(
    path: str | Path,
    data: JSONType,
    overrides: JSONType | None = None,
    verbose: bool = False,
) -> None:
    """Save JSON dictionary to file, with overrides."""

    # New dict to prevent mutation of original
    new_data = {}

    # Append any extra data (also overrides info if duplicate keys)
    if overrides is not None:
        new_data = {**data, **overrides}

    # Convert paths to strings
    for k, v in new_data.items():
        if isinstance(v, Path):
            new_data[k] = str(v)
        else:
            new_data[k] = v

    # Save to json
    text = json.dumps(new_data, indent=4)
    Path(path).write_text(text)

    if verbose:
        print(f"{text}\nSaved to: {path}")


def load_json(
    path: str | Path,
    path_cols: list[str] | None = None,
    verbose: bool = False,
) -> JSONType:
    """Load JSON dictionary from file."""

    # Load from file
    with open(path, "r") as f:
        data = json.load(f)

    # Convert paths to strings
    if path_cols is not None:
        for name in path_cols:
            data[name] = Path(data[name])

    if verbose:
        print(f"{json.dumps(data, indent=4)}\nLoaded from: {path}")

    return data


def save_db(
    df: pd.DataFrame,
    db_path: Path | str,
    table: str,
    if_exists: Literal["fail", "replace", "append"] = "replace",
    index: bool = False,
    verbose: bool = False,
) -> None:
    """Save DataFrame to sqlite3 db as specified table.
    NOTE : default behaviour is to replace the table if it exists."""
    conn = sqlite3.connect(str(db_path))

    if len(df.columns) == 0:
        print(f"Cannot save empty df ->\n{df}")
        return

    df.to_sql(table, conn, if_exists=if_exists, index=index)
    if verbose:
        print(df)
        print(df.columns)
        print(f"Saved to => {table} => {db_path}")


def load_db(
    db_path: Path | str,
    table: str,
    verbose: bool = False,
) -> pd.DataFrame:
    """Read sqlite3 db, return all rows from specified table."""
    conn = sqlite3.connect(str(db_path))
    df = pd.read_sql_query(f"SELECT * from '{table}'", conn)
    if verbose:
        print(df)
        print(df.columns)
    return df
