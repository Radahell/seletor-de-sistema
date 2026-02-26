-- Make CPF unique (remove duplicates first if any, keeping the most recent)
-- Then add UNIQUE constraint

-- Remove the old non-unique index if it exists
DROP INDEX idx_users_cpf ON users;

-- Add UNIQUE index
ALTER TABLE users ADD UNIQUE INDEX uq_users_cpf (cpf);
