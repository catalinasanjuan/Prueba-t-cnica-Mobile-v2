import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NotesService } from './notes.service';
import { Note } from './note.entity';
import { NotFoundException } from '@nestjs/common';

describe('NotesService', () => {
  let service: NotesService;
  let repo: Repository<Note>;

  const mockNote = {
    id: '1',
    title: 'Test Note',
    content: 'Test Content',
    userId: 'user1',
    createdAt: new Date(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotesService,
        {
          provide: getRepositoryToken(Note),
          useValue: {
            create: jest.fn().mockReturnValue(mockNote),
            save: jest.fn().mockResolvedValue(mockNote),
            find: jest.fn().mockResolvedValue([mockNote]),
            findOne: jest.fn().mockResolvedValue(mockNote),
            remove: jest.fn().mockResolvedValue(undefined),
          },
        },
      ],
    }).compile();

    service = module.get<NotesService>(NotesService);
    repo = module.get<Repository<Note>>(getRepositoryToken(Note));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a note', async () => {
      const createNoteDto = { title: 'Test Note', content: 'Test Content' };
      const result = await service.create(createNoteDto, 'user1');
      expect(result).toEqual(mockNote);
      expect(repo.create).toHaveBeenCalledWith({
        ...createNoteDto,
        userId: 'user1',
      });
    });
  });

  describe('findAll', () => {
    it('should return an array of notes', async () => {
      const result = await service.findAll('user1');
      expect(result).toEqual([mockNote]);
      expect(repo.find).toHaveBeenCalledWith({
        where: { userId: 'user1' },
        order: { createdAt: 'DESC' },
      });
    });
  });

  describe('findOne', () => {
    it('should return a note', async () => {
      const result = await service.findOne('1', 'user1');
      expect(result).toEqual(mockNote);
    });

    it('should throw NotFoundException when note not found', async () => {
      jest.spyOn(repo, 'findOne').mockResolvedValueOnce(null);
      await expect(service.findOne('1', 'user1')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('remove', () => {
    it('should remove a note', async () => {
      await service.remove('1', 'user1');
      expect(repo.remove).toHaveBeenCalledWith(mockNote);
    });

    it('should throw NotFoundException when note not found', async () => {
      jest.spyOn(repo, 'findOne').mockResolvedValueOnce(null);
      await expect(service.remove('1', 'user1')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});