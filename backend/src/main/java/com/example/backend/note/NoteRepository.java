package com.example.backend.note;

import org.springframework.data.jpa.repository.JpaRepository;

public interface NoteRepository extends JpaRepository<NoteEntity, Long> {
}
