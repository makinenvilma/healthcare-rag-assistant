CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE documents (
    id           SERIAL PRIMARY KEY,
    slug         TEXT UNIQUE NOT NULL,
    title        TEXT NOT NULL,
    category     TEXT NOT NULL,
    version      TEXT NOT NULL,
    valid_from   DATE NOT NULL,
    valid_to     DATE,
    roles        TEXT[] NOT NULL,
    content_hash TEXT NOT NULL
);

CREATE TABLE chunks (
    id           SERIAL PRIMARY KEY,
    document_id  INT NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    section_path TEXT NOT NULL,
    content      TEXT NOT NULL,
    embedding    vector(1024) NOT NULL,
    tsv          tsvector GENERATED ALWAYS AS (to_tsvector('finnish', content)) STORED
);

CREATE INDEX chunks_embedding_idx ON chunks USING hnsw (embedding vector_cosine_ops);
CREATE INDEX chunks_tsv_idx ON chunks USING gin (tsv);
