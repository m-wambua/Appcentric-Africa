namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Paper;
use Illuminate\Http\Request;

class PaperController extends Controller
{
    public function index(Request $request)
    {
        $query = Paper::with('subject');

        // Filter by subject
        if ($request->has('subject')) {
            $query->whereHas('subject', function ($q) use ($request) {
                $q->where('code', $request->subject)
                  ->orWhere('name', 'like', '%' . $request->subject . '%');
            });
        }

        // Filter by year
        if ($request->has('year')) {
            $query->where('year', $request->year);
        }

        // Search functionality
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        $papers = $query->orderBy('year', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $papers
        ]);
    }

    public function show($id)
    {
        $paper = Paper::with([
            'subject',
            'questions' => function ($query) {
                $query->orderBy('order')->with('answers');
            }
        ])->find($id);

        if (!$paper) {
            return response()->json([
                'success' => false,
                'message' => 'Paper not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $paper
        ]);
    }
}