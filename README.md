<!-- ABOUT THE PROJECT -->
## About The Project
Create PostgreSQL 15.4 with PostGIS and Uber's H3 extension in docker container and some pre-installed h3 tables.

### Prerequisites

It's needed docker to be installed on your machine. You can download Docker from the [official site](https://www.docker.com/products/docker-desktop/)

### Installation

1. Clone the repository
    ```bash
    git clone https://github.com/ConstantineMalykhin/pg_h3.git
    cd pg_h3
    ```

2. Build docker-compose
    ```bash
    docker-compose build
    ```

3. Up docker-compose
    ```bash
    docker-compose up -d
    ```

Since then docker-compose run in detached mode, you can connect to PostgreSQL with the credentials that were provided in docker-compose setup:
    - POSTGRES_USER: admin
    - POSTGRES_PASSWORD: admin
    - POSTGRES_DB: postgres

For example, you can connect to DB via [DBeaver](https://dbeaver.io/).

After connecting to DB, you can see h3 schema that already contains table 'hex' with hexagons of 0 and 1 resolution.
<br></br>
<img src="./img/h3.png" width="400" height="400">

To create hexagons with 2, 3, and etc resolutions run this code

  ```sql
  INSERT INTO h3.hex (ix, resolution, geom)
  SELECT h3_cell_to_children(ix) AS ix,
         resolution + 1 AS resolution,
         ST_Multi(h3_cell_to_boundary_geometry(h3_cell_to_children(ix))) AS geom
    FROM h3.hex 
   WHERE resolution IN (SELECT MAX(resolution) FROM h3.hex);
  ```
More about Uber's H3 you can find [here](https://h3geo.org/)

<!-- CONTACT -->
## Contact
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/github_username/repo_name.svg?style=for-the-badge
[contributors-url]: https://github.com/ConstantineMalykhin
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/constantinemalykhin/
[product-screenshot]: img/h3.png