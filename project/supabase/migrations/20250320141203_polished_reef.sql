/*
  # Create notes table

  1. New Tables
    - `notes`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `title` (text)
      - `content` (text)
      - `created_at` (timestamp with timezone)

  2. Security
    - Enable RLS on `notes` table
    - Add policies for users to:
      - Create their own notes
      - Read their own notes
      - Update their own notes
      - Delete their own notes
*/

CREATE TABLE IF NOT EXISTS notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) NOT NULL,
  title text NOT NULL,
  content text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to create their own notes
CREATE POLICY "Users can create their own notes"
  ON notes
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy to allow users to read their own notes
CREATE POLICY "Users can read their own notes"
  ON notes
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy to allow users to update their own notes
CREATE POLICY "Users can update their own notes"
  ON notes
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy to allow users to delete their own notes
CREATE POLICY "Users can delete their own notes"
  ON notes
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);