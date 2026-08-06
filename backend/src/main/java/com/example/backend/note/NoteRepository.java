package com.example.backend.note;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface NoteRepository extends JpaRepository<NoteEntity, Long> {
    public List<NoteEntity> findByDate(LocalDate date);
}
