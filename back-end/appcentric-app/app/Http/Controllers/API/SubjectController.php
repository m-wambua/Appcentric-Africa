namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Subject;
use Illuminate\Http\Request;

class SubjectController extends Controller
{
    public function index()
    {
        $subjects = Subject::withCount('papers')
            ->orderBy('name')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $subjects
        ]);
    }
}