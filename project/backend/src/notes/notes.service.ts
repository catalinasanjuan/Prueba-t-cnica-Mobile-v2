// Notes service implementation
// Handles all note-related business logic
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Note } from './note.entity';
import { CreateNoteDto } from './dto/create-note.dto';
import { UpdateNoteDto } from './dto/update-note.dto';

@Injectable()
export class NotesService {
  constructor(
    @InjectRepository(Note)
    private notesRepository: Repository<Note>,
  ) {}

  /**
   * Creates a new note for a user
   * @param createNoteDto - The note data
   * @param userId - The ID of the user creating the note
   * @returns The created note
   */
  async create(createNoteDto: CreateNoteDto, userId: string): Promise<Note> {
    const note = this.notesRepository.create({
      ...createNoteDto,
      userId,
    });
    return this.notesRepository.save(note);
  }

  /**
   * Retrieves all notes for a specific user
   * @param userId - The ID of the user
   * @returns Array of notes
   */
  async findAll(userId: string): Promise<Note[]> {
    return this.notesRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Retrieves a specific note by ID
   * @param id - The note ID
   * @param userId - The ID of the user
   * @returns The note if found
   * @throws NotFoundException if the note doesn't exist
   */
  async findOne(id: string, userId: string): Promise<Note> {
    const note = await this.notesRepository.findOne({
      where: { id, userId },
    });
    if (!note) {
      throw new NotFoundException(`Note with ID ${id} not found`);
    }
    return note;
  }

  /**
   * Updates a note
   * @param id - The note ID
   * @param updateNoteDto - The updated note data
   * @param userId - The ID of the user
   * @returns The updated note
   * @throws NotFoundException if the note doesn't exist
   */
  async update(id: string, updateNoteDto: UpdateNoteDto, userId: string): Promise<Note> {
    const note = await this.findOne(id, userId);
    Object.assign(note, updateNoteDto);
    return this.notesRepository.save(note);
  }

  /**
   * Deletes a note
   * @param id - The note ID
   * @param userId - The ID of the user
   * @throws NotFoundException if the note doesn't exist
   */
  async remove(id: string, userId: string): Promise<void> {
    const note = await this.findOne(id, userId);
    await this.notesRepository.remove(note);
  }
}