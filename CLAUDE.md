# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains SQL problem sets and exercises designed to teach MySQL using the Sakila sample database. The exercises progress from basic queries to advanced topics like joins, functions, subqueries, and CTEs (Common Table Expressions). All tasks include Lithuanian-language comments and descriptions.

## Database Context

- **Database**: Sakila (MySQL sample database for a DVD rental store)
- **Dialect**: MySQL
- **Key tables**: actor, film, customer, rental, payment, store, address, city, country, category, inventory, film_actor, film_category, film_text, staff

## SQL File Structure

Each SQL file follows a consistent structure:
- Vim modeline at the top: `-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4`
- Header comment block with problem set title and description (in Lithuanian)
- `USE sakila;` statement
- Numbered tasks with Lithuanian descriptions followed by SQL queries
- Tasks are separated by blank lines

## SQLFluff Configuration

The repository uses SQLFluff for SQL linting with these settings:
- **Dialect**: mysql
- **Max line length**: 79 characters

To lint SQL files:
```bash
sqlfluff lint <file>.sql
```

To fix auto-fixable issues:
```bash
sqlfluff fix <file>.sql
```

## Style Guidelines

SQL queries in this repository follow specific style conventions documented in `style_considerations.md`:

- **Indentation**: 4 spaces, aligned query blocks
- **Casing**: SQL keywords in UPPERCASE; table/column names in lowercase
- **Aliases**: Use meaningful short aliases (e.g., `AS a`, `AS f`, `AS c`)
- **Joins**: INNER JOIN syntax with ON clauses on separate indented lines
- **WHERE/HAVING**: Conditions on separate lines when multiple exist
- **ORDER BY**: Explicit ASC/DESC keywords always included
- **Column selection**: Avoid `SELECT *`; list specific columns needed
- **Comments**: Task numbers and descriptions in Lithuanian before each query
- **Formatting**: Semicolon at end of each query; blank line between tasks

Example style:
```sql
-- 2. Suskaičiuoti kiek filmų yra nusifilmavę aktoriai.
SELECT
    a.actor_id,
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) AS film_count
FROM
    actor AS a
INNER JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY film_count DESC
LIMIT 10;
```

## Problem Set Files

1. **01_sql_basic.sql** - Basic SELECT, WHERE, GROUP BY, aggregate functions
2. **02_sql_basic_additional.sql** - Additional basic exercises
3. **03_sql_joins_tasks.sql** - INNER JOINs with multiple tables
4. **04_sql_joins_tasks_part_2.sql** - More complex join scenarios
5. **05_mysql_functions_tasks.sql** - MySQL functions (DATE, LEFT, COUNT, etc.)
6. **06_mysql_subquery_cte_tasks__compulsory.sql** - Subqueries and CTEs (required)
7. **07_subqueries_tasks_sakila__optional.sql** - Advanced subqueries (optional)

## Common Query Patterns

### Aggregation with grouping
```sql
SELECT column, COUNT(*) AS count
FROM table
GROUP BY column
ORDER BY count DESC;
```

### Multi-table joins
```sql
SELECT t1.col, t2.col, t3.col
FROM table1 AS t1
INNER JOIN table2 AS t2
    ON t1.id = t2.fk_id
INNER JOIN table3 AS t3
    ON t2.id = t3.fk_id
WHERE condition
ORDER BY t1.col ASC;
```

### CTEs with conditional logic
```sql
WITH summary AS (
    SELECT
        entity_id,
        COUNT(*) AS cnt,
        SUM(amount) AS total
    FROM table
    GROUP BY entity_id
)
SELECT
    cnt,
    total,
    CASE
        WHEN total >= 150 THEN 'High'
        WHEN total >= 50 THEN 'Medium'
        ELSE 'Low'
    END AS category
FROM summary
ORDER BY total DESC;
```

## Working with This Repository

### Editing SQL queries
- Read the task description (in Lithuanian)
- Maintain exact formatting and style consistency
- Test queries against the Sakila database
- Ensure line length stays under 79 characters
- Add explicit ASC/DESC to ORDER BY clauses
- Use meaningful aliases consistently

### Adding new queries
- Follow the numbered task format
- Include Lithuanian task description as a comment
- Add blank lines before and after each task block
- End queries with semicolon
- Group related columns in GROUP BY to match SELECT

### Debugging queries
MySQL date arithmetic can cause unsigned subtraction errors. Use explicit type casting or comparison operators instead of arithmetic when working with dates.
