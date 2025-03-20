import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody, ApiParam } from '@nestjs/swagger';
import { NotesService } from './notes.service';
import { CreateNoteDto } from './dto/create-note.dto';
import { UpdateNoteDto } from './dto/update-note.dto';
import { Note } from './note.entity';

@ApiTags('notes')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@Controller('notes')
export class NotesController {
  constructor(private readonly notesService: NotesService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new note' })
  @ApiResponse({ 
    status: 201, 
    description: 'Note successfully created',
    type: Note
  })
  @ApiBody({ type: CreateNoteDto })
  create(@Body() createNoteDto: CreateNoteDto, @Request() req) {
    return this.notesService.create(createNoteDto, req.user.userId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all notes for the authenticated user' })
  @ApiResponse({ 
    status: 200, 
    description: 'Return all notes',
    type: [Note]
  })
  findAll(@Request() req) {
    return this.notesService.findAll(req.user.userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a specific note' })
  @ApiResponse({ 
    status: 200, 
    description: 'Return the note',
    type: Note
  })
  @ApiParam({ name: 'id', type: 'string' })
  findOne(@Param('id') id: string, @Request() req) {
    return this.notesService.findOne(id, req.user.userId);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a note' })
  @ApiResponse({ 
    status: 200, 
    description: 'Note successfully updated',
    type: Note
  })
  @ApiParam({ name: 'id', type: 'string' })
  @ApiBody({ type: UpdateNoteDto })
  update(
    @Param('id') id: string,
    @Body() updateNoteDto: UpdateNoteDto,
    @Request() req,
  ) {
    return this.notesService.update(id, updateNoteDto, req.user.userId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a note' })
  @ApiResponse({ 
    status: 200, 
    description: 'Note successfully deleted'
  })
  @ApiParam({ name: 'id', type: 'string' })
  remove(@Param('id') id: string, @Request() req) {
    return this.notesService.remove(id, req.user.userId);
  }
}