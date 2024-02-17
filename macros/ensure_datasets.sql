{%- macro ensure_datasets() -%}

{% do dataset(
    description="PyPI Vulnerabilities Published Dataset",
    labels=[
        ("stability", "stable"),
        ("data_classification", "public")
    ],
    grant_public=True)
-%}

{%- do dataset(
    sub_dataset_name="internal",
    description="PyPI Vulnerabilities Internal Dataset",
    labels=[
        ("stability", "unstable"),
        ("data_classification", "public")
    ],
    grant_public=True)
-%}

{%- do dataset(
    sub_dataset_name="billing",
    description="GCP Billing for PyPI Vulnerabilities Project",
    labels=[
        ("stability", "unstable"),
        ("data_classification", "public")
    ],
    grant_public=True)
-%}

{%- endmacro -%}
