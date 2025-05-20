import pandas as pd
from pathlib import Path
from dotenv import load_dotenv
import subprocess

load_dotenv()


def replace_parent(file: str | Path, parent: str | Path) -> Path:
    file = Path(file)
    parent = Path(parent)
    # if no parent given, replace with this parent. otherwise return as is
    if file.parent == Path("."):
        return parent / file
    else:
        return file


def replace_ext(file: str | Path, ext: str) -> Path:
    file = Path(file)
    return file.with_suffix(ext)


def none_if(x: str, to_replace: str) -> str | None:
    if x == to_replace:
        return None
    else:
        return x


def sep_files(
    files: str,
    parent: str | Path = "data",
    ext: str = ".rda",
    set_parent: bool = False,
    set_ext: bool = False,
) -> list[Path]:
    """
    Split a string of space-delimited file paths into a list of Path objs with parent directory tacked on.
    """
    if files == "":
        return []
    else:
        file_list = files.split(" ")
        if set_parent:
            file_list = [replace_parent(file, parent) for file in file_list]
        if set_ext:
            file_list = [replace_ext(file, ext) for file in file_list]
        return file_list


def prep_datasets(path: str, sep: str = ";", index="script") -> pd.DataFrame:
    # shell('bash ./data-raw/data_catalog.sh')
    datasets = pd.read_csv(path, sep=sep, index_col=index, keep_default_na=False)
    datasets["input"] = datasets["input"].apply(sep_files)
    datasets["output"] = datasets["output"].apply(
        sep_files, set_parent=True, set_ext=True
    )
    return datasets


def get_inputs(df: pd.DataFrame, script: str) -> list[Path] | list[str]:
    return df.loc[script, "input"]


def get_outputs(df: pd.DataFrame, script: str) -> list[Path] | list[str]:
    return df.loc[script, "output"]


def get_funcs():
    return list(Path("R").glob("*.R"))


def get_tests():
    scripts = Path("tests").glob("**/*.R")
    data = Path("tests/testthat/test_data").glob("**/*")
    return list(scripts) + list(data)


def get_vignettes():
    return list(Path("vignettes").glob("*.qmd"))


def run_r(x: str):
    code = f"Rscript -e '{x}'"
    print(code)
    shell(code)
    return None


datasets = prep_datasets("data-raw/datasets.txt")


def create_rule(script):
    inputs  = get_inputs(datasets, script)
    outputs = get_outputs(datasets, script)

    rule:
        name:
            f"make_{script}"
        input:
            "data-raw/datasets.txt",
            inputs,
            f"data-raw/make_{script}.R",
        output:
            outputs,
        # script:
        #     f"data-raw/make_{script}.R"
        shell:
            f"Rscript data-raw/make_{script}.R"


# rule make_datasets:
#     input:
#         lambda wildcards: data_inputs[wildcards.script],
#     output:
#         'flags/.{script}_done',
#     script:
#         'data-raw/make_{script}.R'
r_files = get_funcs()
test_files = get_tests()
doc_files = get_vignettes()


envvars:
    "CENSUS_API_KEY",
    "BLS_KEY",

rule nhoods:
    output:
        "data-raw/files/all_city_nhoods.rds"
    shell:
        "bash ./data-raw/get_nhood_geos.sh"

rule setup:
    output:
        catalog = 'data-raw/datasets.txt',
    shell:
        "bash ./data-raw/data_catalog.sh"

for script in datasets.index:
    create_rule(script)



rule all_data:
    input:
        datasets["output"],
    output:
        flag=touch("flags/.all_data"),


rule check:
    input:
        rules.all_data.output.flag,
        'R/sysdata.rda',
        "DESCRIPTION",
        r_files,
        test_files,
    output:
        flag=touch("flags/.check"),
    run:
        run_r(
              """
                devtools::check(
                    document = TRUE,
                    cran = FALSE,
                    args = c(\"--run-dontrun\"))
              """
        )


# test is just a subset of check
rule test:
    input:
        rules.all_data.output.flag,
        r_files,
        test_files,
    output:
        flag=touch("flags/.test"),
    run:
        run_r("devtools::test()")


rule document:
    input:
        rules.all_data.output.flag,
        'R/sysdata.rda',
        r_files,
        doc_files,
        readme = 'README.qmd',
    output:
        flag=touch('flags/.document'),
        readme = 'README.md',
    run:
        run_r("devtools::document()")
        shell("quarto render {input.readme}")


rule site:
    input:
        doc_files,
        "README.qmd",
        "_pkgdown.yml",
        "DESCRIPTION",
        "LICENSE",
        check=rules.check.output.flag,
    output:
        flag=touch("flags/.site"),
    run:
        run_r("pkgdown::build_site(run_dont_run = TRUE)")


rule coverage:
    input:
        r_files,
        test_files,
        ".covrignore",
    output:
        report="coverage.html",
    run:
        run_r(
            """
            covr::report(
                covr::package_coverage(quiet = FALSE),
                file = \"coverage.html\",
                browse = FALSE
            )
            """
        )


rule quarto:
    input:
        qmd="{dir}{doc}.qmd",
    output:
        md="{dir}{doc}.md",
    wildcard_constraints:
        dir=r"[\w\-]*?/?",
    shell:
        "quarto render {input.qmd}"


rule dag:
    input:
        "Snakefile",
    output:
        png="dag.png",
    shell:
        "snakemake --filegraph | dot -T png > {output.png}"


rule all:
    default_target: True
    input:
        readme="README.md",
        dag="dag.png",
        all_data=rules.all_data.output.flag,
        check=rules.check.output.flag,
        site=rules.site.output.flag,
        # coverage=rules.coverage.output.report,
