import React, { useState, useEffect } from 'react';
import { LogIn, UserPlus, FileText, LogOut, Loader2, Plus, X } from 'lucide-react';
import { toast, Toaster } from 'react-hot-toast';
import { supabase } from './lib/supabase';

interface Note {
  id: string;
  title: string;
  content: string;
  created_at: string;
}

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isRegistering, setIsRegistering] = useState(false);
  const [notes, setNotes] = useState<Note[]>([]);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isAddingNote, setIsAddingNote] = useState(false);
  const [newNote, setNewNote] = useState({ title: '', content: '' });

  useEffect(() => {
    if (!supabase) {
      toast.error('Please connect to Supabase first using the "Connect to Supabase" button in the top right.');
      return;
    }

    // Check current auth status
    supabase.auth.getSession().then(({ data: { session } }) => {
      setIsAuthenticated(!!session);
      if (session) {
        fetchNotes();
      }
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setIsAuthenticated(!!session);
      if (session) {
        fetchNotes();
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const fetchNotes = async () => {
    if (!supabase) return;

    try {
      const { data, error } = await supabase
        .from('notes')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setNotes(data || []);
    } catch (error) {
      toast.error('Failed to fetch notes');
      console.error('Error:', error);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!supabase) {
      toast.error('Please connect to Supabase first');
      return;
    }

    setIsLoading(true);

    try {
      if (isRegistering) {
        const { error } = await supabase.auth.signUp({
          email,
          password,
        });
        if (error) throw error;
        toast.success('Registro de usuario exitoso');
      } else {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        });
        if (error) throw error;
        setIsAuthenticated(true);
        toast.success('Bienvenido!');
      }
    } catch (error) {
      toast.error(error instanceof Error ? error.message : 'Un error ha ocurrido');
    } finally {
      setIsLoading(false);
    }
  };

  const handleLogout = async () => {
    if (!supabase) {
      toast.error('Supabase client not initialized');
      return;
    }

    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
      setIsAuthenticated(false);
      setNotes([]);
      toast.success('Cierre de sesión exitoso');
    } catch (error) {
      toast.error(error instanceof Error ? error.message : 'A ocurrido un error');
    }
  };

  const handleAddNote = async () => {
    if (!supabase) return;
    
    const { data: { session } } = await supabase.auth.getSession();
    if (!session?.user?.id) {
      toast.error('Debes iniciar sesión para agregar una nota');
      return;
    }

    if (!newNote.title.trim() || !newNote.content.trim()) {
      toast.error('Por favor ingresa un título y contenido para la nota');
      return;
    }

    try {
      const { error } = await supabase
        .from('notas')
        .insert([
          {
            title: newNote.title,
            content: newNote.content,
            user_id: session.user.id
          }
        ]);

      if (error) throw error;

      toast.success('Nota agregada exitosamente');
      setNewNote({ title: '', content: '' });
      setIsAddingNote(false);
      fetchNotes();
    } catch (error) {
      toast.error('Falló al agregar la nota');
      console.error('Error:', error);
    }
  };

  const AuthForm = () => (
    <div className="w-full max-w-md">
      <h2 className="text-3xl font-bold text-center mb-8">
        {isRegistering ? 'Crea una cuenta' : 'Bienvenido'}
      </h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-gray-700">
            Email
          </label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2"
            required
          />
        </div>
        <div>
          <label htmlFor="password" className="block text-sm font-medium text-gray-700">
            Contraseña
          </label>
          <input
            type="password"
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2"
            required
          />
        </div>
        <button
          type="submit"
          disabled={isLoading}
          className="w-full flex justify-center items-center gap-2 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isLoading ? (
            <Loader2 className="animate-spin" size={20} />
          ) : isRegistering ? (
            <>
              <UserPlus size={20} /> Registrate
            </>
          ) : (
            <>
              <LogIn size={20} /> Inicia sesión
            </>
          )}
        </button>
      </form>
      <p className="mt-4 text-center text-sm text-gray-600">
        {isRegistering ? '¿Tienes una cuenta?' : "¿No tienes una cuenta?"}{' '}
        <button
          onClick={() => setIsRegistering(!isRegistering)}
          className="font-medium text-indigo-600 hover:text-indigo-500"
        >
          {isRegistering ? 'Inicia sesión' : 'Registrate'}
        </button>
      </p>
    </div>
  );

  const AddNoteForm = () => (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg p-6 w-full max-w-md">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-xl font-semibold">Agregar nueva Nota</h3>
          <button
            onClick={() => setIsAddingNote(false)}
            className="text-gray-500 hover:text-gray-700"
          >
            <X size={20} />
          </button>
        </div>
        <div className="space-y-4">
          <div>
            <label htmlFor="title" className="block text-sm font-medium text-gray-700">
              Título
            </label>
            <input
              type="text"
              id="title"
              value={newNote.title}
              onChange={(e) => setNewNote({ ...newNote, title: e.target.value })}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2"
              placeholder="Título de la Nota"
            />
          </div>
          <div>
            <label htmlFor="content" className="block text-sm font-medium text-gray-700">
              Contenido
            </label>
            <textarea
              id="content"
              value={newNote.content}
              onChange={(e) => setNewNote({ ...newNote, content: e.target.value })}
              rows={4}
              className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 p-2"
              placeholder="Contenido de la Nota"
            />
          </div>
          <button
            onClick={handleAddNote}
            className="w-full bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 flex items-center justify-center gap-2"
          >
            <Plus size={20} /> Agregar Nota
          </button>
        </div>
      </div>
    </div>
  );

  const NotesApp = () => (
    <div className="w-full max-w-4xl">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold flex items-center gap-2">
          <FileText /> Mis Notas
        </h1>
        <button
          onClick={handleLogout}
          className="flex items-center gap-2 py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700"
        >
          <LogOut size={20} /> Cerrar Sesión
        </button>
      </div>
      <div className="bg-white rounded-lg shadow p-6">
        <div className="mb-6">
          <button
            onClick={() => setIsAddingNote(true)}
            className="bg-indigo-600 text-white px-4 py-2 rounded-md hover:bg-indigo-700 flex items-center gap-2"
          >
            <Plus size={20} /> Agregar nueva Nota
          </button>
        </div>
        <div className="space-y-4">
          {notes.length === 0 ? (
            <p className="text-center text-gray-500">No Hay Notas ¡Crea tu primera Nota!</p>
          ) : (
            notes.map((note) => (
              <div key={note.id} className="border rounded-lg p-4">
                <h3 className="text-xl font-semibold">{note.title}</h3>
                <p className="text-gray-600 mt-2">{note.content}</p>
                <p className="text-sm text-gray-400 mt-2">
                  {new Date(note.created_at).toLocaleDateString()}
                </p>
              </div>
            ))
          )}
        </div>
      </div>
      {isAddingNote && <AddNoteForm />}
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-100 py-12 px-4 sm:px-6 lg:px-8">
      <div className="flex flex-col items-center justify-center">
        {isAuthenticated ? <NotesApp /> : <AuthForm />}
      </div>
      <Toaster position="top-right" />
    </div>
  );
}

export default App;