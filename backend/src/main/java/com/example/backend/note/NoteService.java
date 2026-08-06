package com.example.backend.note;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class NoteService {
    private final NoteRepository noteRepository;
}
