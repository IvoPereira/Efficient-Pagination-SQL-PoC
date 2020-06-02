<h4 align="center">How to Create an Efficient Pagination in SQL (PoC)</h4>

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#credits">How To Run</a> •
  <a href="#observations">Observations</a> •
  <a href="#license">License</a>
</p>

## Overview

This proof of content proves that the most widely used way of making a pagination in most RDBMS - using LIMIT and OFFSET - is not the most efficient one, clearly observed when you start gathering huge amounts of data and need to paginate through them.

To run our experiment, we made available a docker-compose infra that loads a 10M rows dump on a MariaDB instance. When running a sequence of commands we are able to compare the efficiency of two different approaches:
- **Using LIMIT and OFFSET:** This approach is the globally accepted as the "way" to do it - and the wrong one as well as it ends up being the most expensive one as it requires the database to perform a full table scan every time it runs without cache. When building a pagination using this approach the developer should pass the OFFSET and the LIMIT to the query.

    ```sql
    SELECT * FROM `docs` LIMIT 10 OFFSET 2850001
    ```

- **Using the last retrieved ID and LIMIT:** This approach is the one we are trying to prove that should be used instead. By directly limiting the query to search from the last retrieved ID, we prevent the database the need to lookup every sequential row and start the lookup directly from where it needs to. When building a pagination using this approach the developer should pass the last retrieved ID in the page before and the LIMIT to the query.

    ```sql
    SELECT * FROM `docs` WHERE id > 2850000 LIMIT 10
    ```

Before running the experiments, we explicitly disable query caching by setting "query_cache_size" to "0", as we want to measure the real impact a bad approach could have<sup>[1](#mariadb-inconsistent-query-cache)</sup>.

<small><a name="mariadb-inconsistent-query-cache">1</a>: [MariaDB's Query Cache is inconsistent across different versions, so we turn it off manually](https://mariadb.com/kb/en/query-cache/)</small>

## How to Run the PoC

To clone and run this PoC, you'll need Git, Docker-Compose and gzip (to unzip the `dump.sql.gz`) installed on your computer.

To run it, start the MariaDB service running the following command:
```sh
make start
```

Once mysqld is ready for connections (something like `mariadb    | 2020-06-02 21:29:12 0 [Note] mysqld: ready for connections.` should appear in the CLI - should take 30-40 seconds), run the PoC in a separate terminal window:
```
make poc
```

Both queries should execute and you should now be able to compare the uncached execution times of both approaches.

## Observations

After running the instructions provided in "How to Run the PoC" these are the results we got:

<p align="center">
  <img src="https://user-images.githubusercontent.com/1396475/83573837-1cdef180-a524-11ea-9ccb-9c0479a8116e.png" alt="Size Approach comparison" width="738">
</p>

As we can observe in a sample provided by the PoC, we have seen an increase of 193171.17% in execution time, considering the first query as the one using the LIMIT/OFFSET and the second one using the last retrieved ID and a LIMIT.

Feel free to run `make poc` several times to compare the results and to take your own conclusions on which is the most efficient option.

Considering this, the second approach should be used to create a Pagination system.

## You may also like...

- [Why You Shouldn't Use OFFSET and LIMIT For Your Pagination](https://ivopereira.net/content/efficient-pagination-dont-use-offset-limit) - Check the original article I have wrote that addresses this Proof of Concept.

## License

MIT

---

> [ivopereira.net](https://ivopereira.net) &nbsp;&middot;&nbsp;
> GitHub [@ivopereira](https://github.com/ivopereira) &nbsp;&middot;&nbsp;
> Twitter [@ivoecpereira](https://twitter.com/ivoecpereira) &nbsp;&middot;&nbsp;
> [LinkedIn](https://linkedin.com/in/ivopereira/)
